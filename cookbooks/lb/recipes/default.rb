ey_cloud_report "load balancer" do
  message 'setting up load balancer'
end

require_recipe 'lb::prep'
require_recipe 'lb::build'
