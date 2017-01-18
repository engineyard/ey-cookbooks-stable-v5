require 'pp'
#
# Cookbook Name:: memcached-custom
# Recipe:: install
#

memcached_version = node['memcached']['version']
memcached_download_url = node['memcached']['download_url']
memcached_installer_directory = '/opt/memcached-installer'

ey_cloud_report "memcached" do
  message "Installing memcached"
end

Chef::Log.info "INSTALL TYPE: #{node['memcached']['install_type']}"
Chef::Log.info "INSTANCE ROLE: #{node['dna']['instance_role']}"
Chef::Log.info "UTILITY NAME: #{node['memcached']['utility_name']}"

is_memcached_instance = case node['memcached']['install_type']
when 'ALL_APP_INSTANCES'
  ['solo', 'app_master', 'app'].include?(node['dna']['instance_role'])
else
  (node['dna']['instance_role'] == 'util') && (node['dna']['name'] == node['memcached']['utility_name'])
end

if is_memcached_instance
  if node['memcached']['install_from_source']
    include_recipe 'memcached::install_from_source'
  else
    include_recipe 'memcached::install_from_package'
  end

  template "/etc/conf.d/memcached" do
    source "memcached.erb"
    owner 'root'
    group 'root'
    mode 0644
    variables :memusage => node['memcached']['memusage'],
      :port     => 11211,
      :misc_opts => node['memcached']['misc_opts']
  end

  directory '/etc/monit.d' do
    owner 'root'
    group 'root'
    mode 0755
    action :create
  end

  template '/etc/monit.d/memcached.monitrc' do
    source 'memcached.monitrc'
    owner 'root'
    group 'root'
    mode 0644
    notifies :run, 'execute[restart-monit]', :delayed
  end
end
