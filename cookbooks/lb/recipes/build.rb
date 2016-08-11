ey_cloud_report "haproxy" do
  message '  installing load balancer'
end

require_recipe 'haproxy::install'
