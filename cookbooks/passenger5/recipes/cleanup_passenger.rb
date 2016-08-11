#
# Cookbook Name:: passenger5
# Recipe:: cleanup_passenger
#

# This renders a commented out stack.conf file
template "/etc/nginx/stack.conf" do
  owner node.engineyard.environment.ssh_username
  group node.engineyard.environment.ssh_username
  mode 0644
  source "nginx_stack.conf.erb"

  variables(
    :stack_type   => "Passenger 5",
    :user         => node.engineyard.environment.ssh_username
  )
end
