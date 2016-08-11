ey_cloud_report "haproxy" do
  message '  configuring load balancer'
end

require_recipe 'haproxy::kill-others'
require_recipe 'haproxy::configure'
