#create the vm.args File


managed_template "/home/#{ssh.username}/vm.args" do
  owner ssh_username
  group ssh_username
  mode 0644
  source "haproxy.cfg.erb"
  variables({
    :name => sg@ec2-1.2.3.4.compute.amazonaws.com,
    :cookie => node.engineyard.environment.app_name,
    :config => /home/ubuntu/your_app.config
  })

managed_template "/home/#{ssh.username}/node['elixir']['config']['file']" do
  owner ssh_username
  group ssh_username
  mode 0644
  source "elixir_app.config.erb"
  variables({
    :optional_nodes => node.engineyard.environment.app_name,
    :sync_timeout => 3000
  })
