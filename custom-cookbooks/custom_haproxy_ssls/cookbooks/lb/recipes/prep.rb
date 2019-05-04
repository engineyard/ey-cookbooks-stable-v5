ey_cloud_report "haproxy" do
  message '  configuring load balancer'
end

require_recipe 'custom-haproxy-ssls::default'
require_recipe 'haproxy::kill-others'
require_recipe 'haproxy::configure'
