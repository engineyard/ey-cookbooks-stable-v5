#create the vm.args File
ssh_username  = node['owner_name']
config = "/home/#{ssh_username}/your_app.config"

set_name = begin
    node['dna']['name'] + "@" + node['ipaddress']
  rescue NoMethodError
    nil
  end
default_name = `hostname`.chomp + "@" + node['ipaddress']
real_name = set_name or default_name
cookie = node['elixir']['cookie']
port  = node['elixir']['port']
framework_env = node.dna['environment']['framework_env']
elixir_map = node['dna']['engineyard']['environment']['instances'].
    compact.
    reject {|instance| instance['id'] == node['dna']['engineyard']['this']}.
    reject {|instance| instance['name'].nil? }.
    select {|instance| ['util', 'app', 'app_master', 'solo'].include? instance['role']}.
    map {|instance| "#{instance['name']}@#{instance['private_hostname']}"}


managed_template "/home/#{node["owner_name"]}/vm.args" do
  owner ssh_username
  group ssh_username
  mode 0644
  source "vmargs.erb"
  variables({
    :name => real_name,
    :cookie => cookie,
    :config => config
  })
end

managed_template "/home/#{node["owner_name"]}/elixir_app.config" do
  owner ssh_username
  group ssh_username
  mode 0644
  source "elixir_app.config.erb"
  variables({
    :optional_nodes => elixir_map,
    :sync_timeout => 3000
  })
end


node.engineyard.apps.each_with_index do |app, index|

  base_port = node['elixir']['port'].to_i
  stepping = 200
  app_base_port = base_port + ( stepping * index )

  elixir_name = app.metadata('elixir_app_name', nil) || app.name

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
      :elixir_name => elixir_name,
      :app_name => app.name,
      :db_host => node.dna['db_host'] ,
      :port => app_base_port
    })
  end

  cookbook_file "/data/#{app.name}/shared/config/customer.secret.exs" do
    source "customer.secret.exs"
    owner node["owner_name"]
    group node["owner_name"]
    mode 0644
    backup 0
    not_if { FileTest.exists?("/data/#{app.name}/shared/config/customer.secret.exs") }
  end

  directory "/data/#{app.name}/shared/deps" do
    owner ssh_username
    group ssh_username
    mode '0755'
    action :create
  end


  template "/etc/monit.d/phoenix_#{app.name}.monitrc" do
    owner node["owner_name"]
    group node["owner_name"]
    mode 0600
    source "phoenix.monitrc.erb"
    variables(
      :app => app.name,
      :elixir_name => elixir_name,
      :user => node["owner_name"]
    )
  end

  template "/engineyard/bin/app_#{app.name}" do
    source "app_control.erb"
    mode 0755
    owner node.engineyard.environment.ssh_username
    group node.engineyard.environment.ssh_username
    backup 0
    variables({
      :app_name      => app.name
    })
  end

end
