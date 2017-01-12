memcached_version = node['memcached']['version']
memcached_download_url = node['memcached']['download_url']
memcached_installer_directory = '/opt/memcached-installer'

Chef::Log.info "Installing memcached #{memcached_version} from source..."

remote_file "/opt/memcached-#{memcached_version}.tar.gz" do
  source "#{memcached_download_url}"
  owner node[:owner_name]
  group node[:owner_name]
  mode 0644
  backup 0
end

execute "unarchive Memcached installer" do
  cwd "/opt"
  command "tar zxf memcached-#{memcached_version}.tar.gz && sync"
end

execute "Remove old memcached-installer" do
  command "rm -rf /opt/memcached-installer"
end

execute "rename /opt/memcached-#{memcached_version} to /opt/memcached-installer" do
  command "mv /opt/memcached-#{memcached_version} #{memcached_installer_directory}"
end

execute "run memcached-installer/configure, make, install" do
  cwd memcached_installer_directory
  command "./configure && make && make install"
end
