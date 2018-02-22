# Update OpenSSL
Chef::Log.info "OpenSSL Version: #{node['openssl']['version']}"

enable_package 'dev-libs/openssl' do
  version node['openssl']['version']
end

package 'dev-libs/openssl' do
  version node['openssl']['using_metadata'] ? node['openssl']['version'] : at_least_version(node['openssl']['version'])
  action :install
end
