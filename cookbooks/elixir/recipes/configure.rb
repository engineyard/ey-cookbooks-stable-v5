#create the vm.args File

config = "/home/#{ssh_username}/your_app.config"
name = `hostname`.chomp + "@" + node['ipaddress']

managed_template "/home/#{ssh.username}/vm.args" do
  owner ssh_username
  group ssh_username
  mode 0644
  source "vmargs.erb"
  variables({
    :name => name,
    :cookie => node.engineyard.environment.app_name,
    :config => config
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
