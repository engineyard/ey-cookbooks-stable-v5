# We need net/http (token PUT) and open-uri (fail-loud GET) for IMDS.
require 'net/http'
require 'open-uri'
require 'timeout'

# Fetch an EC2 instance metadata value using IMDSv2 (token handshake) with a
# plain-GET fallback. Under HttpTokens=required a plain unauthenticated IMDSv1
# GET returns 401. If the token PUT fails we fall back to an unauthenticated
# GET. Mirrors the Stack v8 ey-prompt helper, using OpenURI.open_uri because
# URI.open needs Ruby 2.5+ and this stack runs Ruby 2.2.
#
# Must fail loud on an error response: the fetched value is interpolated into
# the shell prompt, and Net::HTTP.get (used here before) returns a non-200
# body (e.g. a 401 error page) as if it were the value. A 404 is treated as
# legitimate absence (no public IPv4/hostname) and returns nil.
def imds_get(path)
  base = 'http://169.254.169.254'
  token = begin
    uri = URI("#{base}/latest/api/token")
    req = Net::HTTP::Put.new(uri.request_uri)
    req['X-aws-ec2-metadata-token-ttl-seconds'] = '21600'
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 5
    http.read_timeout = 5
    res = http.start { |connection| connection.request(req) }
    res.is_a?(Net::HTTPSuccess) && !res.body.to_s.empty? ? res.body : nil
  rescue StandardError
    nil
  end
  headers = token ? { 'X-aws-ec2-metadata-token' => token } : {}
  headers[:read_timeout] = 5
  Timeout.timeout(5) do
    OpenURI.open_uri("#{base}/#{path}", headers) { |io| io.read }
  end
rescue OpenURI::HTTPError => e
  return nil if e.io.status.first == '404'
  raise
end

# Grab the public hostname for this instance. This recipe
# will be run *from* the instance, which means that the following
# IP address will be resolved internally from Amazon, which
# is good because it's an Amazon-specific, internal IP
# that they use for instance metadata.
public_hostname = imds_get('latest/meta-data/public-hostname')
# Getting public IP address if assigned
public_ip_address = imds_get('latest/meta-data/public-ipv4')
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
