## Symlink /etc/nginx to the /data EBS
execute "remove /etc/nginx" do
  command "rm -rf /etc/nginx"
  action :run
  only_if "[[ -d /etc/nginx ]]"
end

directory "/data/nginx" do
  owner node['owner_name']
  group node['owner_name']
  mode 0775
end

link "/etc/nginx" do
  to "/data/nginx"
end

## /data/nginx/ files

%w{mime.types koi-utf koi-win}.each do |p|
  cookbook_file "/data/nginx/#{p}" do
    owner node['owner_name']
    group node['owner_name']
    mode 0755
    source p
    backup 0
  end
end

pool_size = get_pool_size()
behind_proxy = true

managed_template "/data/nginx/nginx.conf" do
  owner node.engineyard.environment.ssh_username
  group node.engineyard.environment.ssh_username
  mode 0644
  source "nginx-plusplus.conf.erb"
  variables(
    :pool_size => pool_size,
    :user =>  node.engineyard.environment.ssh_username,
    :behind_proxy => behind_proxy
  )
  notifies node['nginx'][:action], resources(:service => "nginx"), :delayed
end

file "/data/nginx/http-custom.conf" do
  action :create_if_missing
  owner node['owner_name']
  group node['owner_name']
  mode 0644
end

## /data/nginx/servers/

directory "/data/nginx/servers" do
  owner node.engineyard.environment.ssh_username
  group node.engineyard.environment.ssh_username
  mode 0755
  recursive true
end

file "/data/nginx/servers/default.conf" do
  owner node['owner_name']
  group node['owner_name']
  mode 0644
end

## /data/nginx/ssl/

directory "/data/nginx/ssl" do
  owner node.engineyard.environment.ssh_username
  group node.engineyard.environment.ssh_username
  mode 0775
end

## /data/nginx/common/

directory "/data/nginx/common" do
  owner node.engineyard.environment.ssh_username
  group node.engineyard.environment.ssh_username
  mode 0755
  recursive true
end

nginx_version = node.engineyard.metadata("nginx_ebuild_version", node['nginx'][:version])

# CC-362: msec is available after version 1.2.7
use_msec = (nginx_version.split('.').map(&:to_i) <=> [1,2,7]) >= 0

managed_template "/data/nginx/common/proxy.conf" do
  owner node.engineyard.environment.ssh_username
  group node.engineyard.environment.ssh_username
  mode 0644
  source "common.proxy.conf.erb"
  variables({
    :use_msec => use_msec
  })
  notifies node['nginx'][:action], resources(:service => "nginx"), :delayed
end

managed_template "/data/nginx/common/servers.conf" do
  owner node.engineyard.environment.ssh_username
  group node.engineyard.environment.ssh_username
  mode 0644
  source "common.servers.conf.erb"
  notifies node['nginx'][:action], resources(:service => "nginx"), :delayed
end

managed_template "/data/nginx/common/fcgi.conf" do
  owner node.engineyard.environment.ssh_username
  group node.engineyard.environment.ssh_username
  mode 0644
  source "common.fcgi.conf.erb"
  notifies node['nginx'][:action], resources(:service => "nginx"), :delayed
end

## /var

directory "/var/log/engineyard/nginx" do
  owner 'root'
  group 'root'
  mode 0755
end


logrotate "nginx" do
  files "/var/log/engineyard/nginx/*log"
  copy_then_truncate true
  restart_command <<-SH
[ ! -f /var/run/nginx.pid ] || kill -USR1 `cat /var/run/nginx.pid`
  SH
end

#TODO: not_if-afy. https://github.com/engineyard/cloud_cookbooks/commit/73e08722ec930cb8884e44594f6350e25c05c509
unless File.symlink?("/var/log/nginx")
  directory "/var/log/nginx" do
    action :delete
    recursive true
  end
end

#TODO: do this on the AMI/ebuild?
link "/var/log/nginx" do
  to "/var/log/engineyard/nginx"
end

# Precreate Nginx Work Directories with Deploy permissions for Passenger
directory "/var/tmp/nginx" do
  owner 'root'
  group 'root'
  mode 0755
end

#TODO: do this on the AMI/ebuild?
directory "/var/tmp/nginx/client" do
  owner node.engineyard.environment.ssh_username
  group node.engineyard.environment.ssh_username

  mode 0775
  recursive true
end

directory "/var/tmp/nginx/fastcgi" do
  owner node.engineyard.environment.ssh_username
  group 'root'
  mode 0700
end

directory "/var/tmp/nginx/proxy" do
  owner node.engineyard.environment.ssh_username
  group 'root'
  mode 0700
  recursive true
end

directory "/var/tmp/nginx/scgi" do
  owner node.engineyard.environment.ssh_username
  group 'root'
  mode 0700
end

directory "/var/tmp/nginx/uwscgi" do
  owner node.engineyard.environment.ssh_username
  group 'root'
  mode 0700
end

## setup /etc/conf.d

managed_template "/etc/conf.d/nginx" do
  source "conf.d/nginx.erb"
  variables({
    :nofile => 16384
  })
  notifies node['nginx'][:action], resources(:service => "nginx"), :delayed
end
