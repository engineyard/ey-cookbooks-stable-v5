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

managed_template "/home/#{node["owner_name"]}/elixir_app.config" do
  owner ssh_username
  group ssh_username
  mode 0644
  source "elixir_app.config.erb"
  variables({
    :optional_nodes => node.engineyard.environment['apps'],
    :sync_timeout => 3000
  })
end


node.engineyard.apps.each do |app|

  managed_template "/data/#{app.name}/shared/config/prod.secret.exs" do
    owner node.engineyard.environment.ssh_username
    group node.engineyard.environment.ssh_username
    mode 0600
    source "prod.secret.exs.erb"
    variables({
      :environment => node.engineyard.environment['framework_env'],
      :dbuser => node.engineyard.environment.ssh_username,
      :dbpass => node.engineyard.environment.ssh_password,
      :dbname => app.database_name,
    })
  end

  directory '/data/#{app.name}/shared/config/deps' do
    owner ssh_username
    group ssh_username
    mode '0755'
    action :create
  end
end
