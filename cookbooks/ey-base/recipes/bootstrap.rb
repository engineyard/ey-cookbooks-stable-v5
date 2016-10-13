include_recipe 'ey-monitor' # stonith
include_recipe "ec2" if ['solo', 'app', 'util', 'app_master','node'].include?(node.dna['instance_role'])

include_recipe 'ey-dynamic::packages'

include_recipe 'ephemeraldisk'

# descriptive hostname

descriptive_hostname = [
  node.dna['engineyard']['this'],
  node.dna['environment']['name'],
  node.dna['instance_role'],
  node.dna['name'],
  node.name,
  `hostname`
].compact.join(',')

execute "write descriptive_hostname file" do
  command "echo '#{descriptive_hostname}' > /etc/descriptive_hostname"
end


include_recipe "ey-dynamic::user"

directory "/data" do
  owner node["owner_name"]
  group node["owner_name"]
  mode 0755
end

directory "/data/homedirs" do
  owner node["owner_name"]
  group node["owner_name"]
  mode '0755'
end

node.dna['applications'].each_key do |app|
  directory "/data/#{app}" do
    owner node["owner_name"]
    group node["owner_name"]
    mode '0755'
  end
end

directory "/var/log/engineyard" do
  owner node["owner_name"]
  group node["owner_name"]
  mode '0755'
end

directory "/var/cache/engineyard" do
  owner node["owner_name"]
  group node["owner_name"]
  mode '0755'
end

%w{/engineyard /engineyard/bin}.each do |dir|
  directory dir do
    owner "root"
    group "root"
    mode '0755'
  end
end

cookbook_file '/etc/security/limits.conf' do
  owner 'root'
  group 'root'
  mode '0644'
  source 'limits.conf'
end

# Not applicable to new kernel
# remote_file '/etc/modules.autoload.d/kernel-2.6' do
#   owner 'root'
#   group 'root'
#   mode 0644
#   source 'kernel-2.6'
#   not_if { node.dna[:kernel][:release].include?("2.6.32") || File.exists?("/etc/modules.autoload.d/keep.kernel-2.6") }
# end

cookbook_file '/etc/env.d/99manpager' do
  owner 'root'
  group 'root'
  mode '0644'
  source '99manpager'
  backup 0
end

cookbook_file '/etc/env.d/25editor' do
  owner 'root'
  group 'root'
  mode '0644'
  source '25editor'
  backup 0
end

cookbook_file '/etc/env.d/02locale' do
  owner 'root'
  group 'root'
  mode '0644'
  source '02locale'
  backup 0
end

cookbook_file '/etc/profile.d/history-helper.sh' do
  owner 'root'
  group 'root'
  mode '0755'
  source 'history-helper.sh'
  backup 0
end

cookbook_file '/etc/env.d/26history' do
  source "26history"
  backup 0
  mode '0644'
  owner 'root'
  group 'root'
end

template '/etc/env.d/05framework_env' do
  owner 'root'
  group 'root'
  mode '0644'
  source '05framework_env.erb'
  backup 0
  variables(
    #:framework_env => node.dna['environment']['framework_env']
    :framework_env => node.engineyard.environment['framework_env']
  )
end

execute "remove framework_env from /etc/profile" do
  command %Q{
    sed -e '/RACK_ENV/d' -e '/MERB_ENV/d' -e '/RAILS_ENV/d' -i /etc/profile
   }
end


# TODO: move to security-updates or its own recipe
# Upgrade ca-certificates to the newest bundle.
enable_package "app-misc/ca-certificates" do
  version "20140325-r1 ~amd64"
end

package "app-misc/ca-certificates" do
  version "20140325-r1"
  action :upgrade
end

execute "update-ca-certificates --fresh" do
 action :nothing
 subscribes :run, 'package[app-misc/ca-certificates]', :delayed
end

# all roles get these recipes
include_recipe 'cron'
include_recipe "ey-env"
include_recipe "ey-bin"
include_recipe "ey-backup::setup"
include_recipe "framework_env"
include_recipe "chef-custom"
include_recipe "sudo"
include_recipe "ssh_keys"
include_recipe "efs"
# do not run the ruby recipes when we install Node.js and other languages.
include_recipe "ruby" if node.engineyard.environment.ruby?
include_recipe "motd" # educational message on login

if node.engineyard.instance.component?(:ssmtp)
  include_recipe "ssmtp"
end

if node.engineyard.instance.component?(:exim)
  exim = node.engineyard.instance.component(:exim)
  exim_auth "default" do
    my_hostname exim['host']
    smtp_host   exim['outbound_host']
    username    exim['user']
    password    exim['password']
  end
end

include_recipe 'cron'
