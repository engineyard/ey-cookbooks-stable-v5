template "/etc/nginx/stack.conf" do
  owner node.engineyard.environment.ssh_username
  group node.engineyard.environment.ssh_username
  mode "0644"
  source "nginx_stack.conf.erb"

  variables(
    :stack_type   => "Unicorn",
    :user         => node.engineyard.environment.ssh_username
  )
end
