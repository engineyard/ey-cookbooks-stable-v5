#create the vm.args File
ssh_username  = node['owner_name']
config = "/home/#{ssh_username}/your_app.config"
name = `hostname`.chomp + "@" + node['ipaddress']
port  = node['elixir']['port']
secret = node['elixir']['secret']
framework_env = node.dna['environment']['framework_env']


service "nginx" do
  action :nothing
  supports :status => false, :restart => true
end

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
      :app_name => app.name,
      :secret => secret,
      :port => port
    })
  end

  cookbook_file "/data/#{app.name}/shared/config/customer.secret.exs" do
    source "customer.secret.exs"
    owner node["owner_name"]
    group node["owner_name"]
    mode 0644
    backup 0
    not_if { FileTest.exists?("/data/#{app_name}/shared/config/customer.secret.exs") }
  end

  directory "/data/#{app.name}/shared/config/deps" do
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
      :user => node["owner_name"]
    )
  end

    nginx_http_port = 8081
    nginx_https_port = 8082
    base_port = node['elixir']['port'].to_i
    stepping = 200
    app_base_port = base_port

  template "/data/nginx/servers/#{app.name}.conf" do
    owner ssh_username
    group ssh_username
    mode 0644
    source "nginx_app.conf.erb"
    cookbook "elixir"
    variables({
      :vhost => app.vhosts.first,
      :port => nginx_http_port,
      :upstream_port => port,
      :framework_env => framework_env
    })
    notifies :restart, resources(:service => "nginx"), :delayed
  end

end
