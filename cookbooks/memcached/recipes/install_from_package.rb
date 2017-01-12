memcached_package = 'net-misc/memcached'
memcached_version = node['memcached']['version']

Chef::Log.info "Installing #{memcached_package} #{memcached_version} from package..."

enable_package memcached_package do
  version memcached_version
  override_hardmask true
  unmask :true
end

package memcached_package do
  version memcached_version
  action :install
end
