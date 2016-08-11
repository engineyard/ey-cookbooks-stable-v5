# Expects configuration to already be done.
#
# FIXME: remove overlay once ebuilds are present in-tree
#

# Update HAProxy
haproxy_version = node.engineyard.metadata("haproxy_ebuild_version", node.haproxy_version)

Chef::Log.info "HAProxy Version: #{haproxy_version}"

unmask_package 'net-proxy/haproxy' do
  version haproxy_version
  unmaskfile 'haproxy'
end

enable_package 'net-proxy/haproxy' do
  version haproxy_version
end

package 'net-proxy/haproxy' do
  version haproxy_version
  action :upgrade
end

service 'haproxy' do
  action :enable
  supports :status => true, :restart => true, :start => true
  subscribes :restart, resources(:package => 'net-proxy/haproxy'), :immediately
end
