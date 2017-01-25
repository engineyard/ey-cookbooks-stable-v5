#create the vm.args File
ssh_username  = node['owner_name']
config = "/home/#{ssh_username}/your_app.config"
name = `hostname`.chomp + "@" + node['ipaddress']


managed_template "/home/#{node["owner_name"]}/vm.args" do
  owner ssh_username
  group ssh_username
  mode 0644
  source "vmargs.erb"
  variables({
    :name => name,
    :cookie => node.engineyard.environment['apps'],
    :config => config
  })
end

managed_template "/home/#{node["owner_name"]}/node['elixir']['config']['file']" do
  owner ssh_username
  group ssh_username
  mode 0644
  source "elixir_app.config.erb"
  variables({
    :optional_nodes => node.engineyard.environment['apps'],
    :sync_timeout => 3000
  })
end
