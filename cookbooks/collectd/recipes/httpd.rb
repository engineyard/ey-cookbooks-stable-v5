include_recipe "nginx::install"

# The above include will cause nginx to be listening unnecessarily
# on port 81 on db / util instances, so we stop it here.
#
# TODO: Split the nginx recipe up so we can include only what we
#       need in this recipe
collectd_nginx_version = node['collectd']['nginx']['version']

unless %w(app_master app solo).include?(node.dna['instance_role'])
  service "nginx" do
    action :stop
    only_if "/etc/init.d/nginx status"
  end
end

directory "/var/www/localhost/htdocs" do
  owner node.engineyard.environment.ssh_username
  group node.engineyard.environment.ssh_username
  mode 0755
  recursive true
end

directory "/etc/collectd-httpd" do
  owner node.engineyard.environment.ssh_username
  group node.engineyard.environment.ssh_username
  mode 0755
  recursive true
end

template "/etc/collectd-httpd/collectd-httpd.conf" do
  owner node.engineyard.environment.ssh_username
  group node.engineyard.environment.ssh_username
  mode 0644
  variables({
    :user => node.engineyard.environment.ssh_username
  })
  source "collectd-httpd.conf.erb"
end

# Preinstalled on 2012.11.009 AMI
#package 'www-misc/fcgiwrap' do
#  version '1.0.3-r1'
#end
#
#package 'www-servers/spawn-fcgi' do
#  version '1.6.3-r1'
#end



cookbook_file "/etc/init.d/collectd-httpd" do
  source 'collectd-httpd.sh'
  owner 'root'
  group 'root'
  mode 0755
  backup 0
end

execute "monit reload" do
  action :nothing
end

cookbook_file "/etc/monit.d/collectd-fcgi.monitrc" do
  source 'collectd-fcgi.monitrc'
  owner 'root'
  group 'root'
  mode 0644
  backup 0
  notifies :run, resources(:execute => "monit reload"), :immediately
end

cookbook_file "/etc/monit.d/collectd-httpd.monitrc" do
  source 'collectd-httpd.monitrc'
  owner 'root'
  group 'root'
  mode 0644
  backup 0
  notifies :run, resources(:execute => "monit reload"), :immediately
end

# Setup HTTP auth so AWSM can get at the graphs
execute "install-http-auth" do
  command %Q{
    htpasswd -cb /etc/collectd-httpd/collectd-httpd.users  engineyard #{node.engineyard.environment['stats_password']}
  }
end

execute "upgrade collectd nginx" do
  action :nothing
  user 'root'
  command '/etc/init.d/collectd-httpd upgrade'
  only_if %Q{
    [[ -f /var/run/collectd-httpd.pid && "$(readlink -m /proc/$(cat /var/run/collectd-httpd.pid)/exe)" =~ '/usr/sbin/nginx' ]]
  }
end

managed_template "/data/nginx/collectd_nginx_version.conf" do
  owner node.engineyard.environment.ssh_username
  group node.engineyard.environment.ssh_username
  mode 0644
  source "collectd_nginx_version.conf.erb"
  variables(
    :version => collectd_nginx_version
  )
  notifies :run, resources(:execute => "upgrade collectd nginx"), :delayed
end

