# We're going to need net/http to initiate an HTTP request to AWS.
require 'net/http'

# Grab the public hostname for this instance. This recipe
# will be run *from* the instance, which means that the following
# IP address will be resolved internally from Amazon, which
# is good because it's an Amazon-specific, internal IP
# that they use for instance metadata.
public_hostname = Net::HTTP.get(
  URI('http://169.254.169.254/latest/meta-data/public-hostname')
)
# Getting public IP address if assigned
public_ip_address = Net::HTTP.get(
  URI('http://169.254.169.254/latest/meta-data/public-ipv4')
)
# Specify the users you want to have this prompt in this array.
#users = [""]

users = Array.new
users << node.engineyard.environment.ssh_username

# This recipe needs to be in a ruby_block because Chef is running in an
# indeterminate order. Don't know which piece runs when, and notifies just
# plain sucks because it doesn't work.
ruby_block :source_prompt do
  block do
    # Write out the prompt file and update ~/.bashrc for each user
    users.each do |u|
      # Put something in the Chef log
      STDOUT.puts "Setting up better bash prompt for user: #{u} ..."

      # Root has a different path for its homedir than other users might,
      # so find this user's home directory
      homedir = `echo /home/#{u}`.chomp

      STDOUT.puts "Found home directory #{homedir} for #{u} ..."

      # If the user doesn't have a .bashrc for some reason, this is going
      # to fail miserably. Check for it and if it's not there, look in
      # /etc/skel/.bashrc. If that isn't there, create a blank file.
      unless File.exist?("#{homedir}/.bashrc")
        # Not there - is it in /etc/skel/.bashrc?
        if File.exist?("/etc/skel/.bashrc")
          `cp /etc/skel/.bashrc #{homedir}/.bashrc`
        else
          `touch #{homedir}/.bashrc`
        end
      end

      # Tell .bashrc to 'source' this file unless it already does
      unless File.read("#{homedir}/.bashrc").match(/\.prompt/)
        File.open("#{homedir}/.bashrc", "a+") do |f|
          f.puts 'source ~/.prompt'
        end
      end
    end # end users loop
  end # end block
end # end chef ruby_block

users.each do |u|
  homedir = `echo /home/#{u}`.chomp
  # Write out ~/.prompt which then gets sourced by ~/.bashrc
  template "#{homedir}/.prompt" do
    action :create
    owner  u
    group  u
    mode   0640 # Read/Write, Read, Nothing (owner, group, world)
    source "prompt.erb"
    variables({
      :user => u,
      :role => node[:instance_role],
      :env_name => node[:environment_name],
      :app_type => node[:application_type],
      :public_hostname => public_hostname,
      :public_ip => public_ip_address
    })
  end
end
