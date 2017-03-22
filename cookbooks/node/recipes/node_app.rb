base_port = 6000

service "nginx" do
  action :nothing
  supports :status => false, :restart => true
end

if node.engineyard.environment["stack_name"] == "node_pm2"
  include_recipe 'pm2'
end

node.engineyard.apps.each_with_index do |app, app_index|

  possible_exts = ['conf', 'tcp_conf'] # remove both styles to allow switching

  if app.recipes.include?('node::tcp')
    mode_hash = {
      :label => "TCP",
      :ext => 'tcp_conf'  # Now uses proxy_http_version 1.1;
    }
  elsif app.recipes.include?('node::standard')
    mode_hash = {
      :label => "HTTP",
      :ext => 'conf'
    }
  else
    next
  end

  app_name = app.name
  app_user = node.engineyard.environment.ssh_username
  app_password = node.engineyard.environment.ssh_password

  ey_cloud_report "node-app-#{app_name}" do
    message "configuring #{app_name} via #{mode_hash[:label]} proxy"
  end

  app_port = base_port + (app_index * 100) # 6000, 6100, 6200

  ["/var/log/engineyard" "/var/log/engineyard/apps", "/var/log/engineyard/apps/#{app_name}"].each do |dir|
    directory dir do
      owner app_user
      group app_user
      mode 0755
      recursive true
    end
  end

  template "/data/#{app_name}/shared/config/env" do
    source "env.erb"
    owner node["owner_name"]
    group node["owner_name"]
    backup 0
    mode 0755
    variables(
      :port => app_port,
      :user => node['owner_name'],
      :framework_env => node.engineyard.environment['framework_env'],
      :home => "/home/#{app_user}",
      :db_user => app_user,
      :db_password => app_password,
      :db_host => node.dna['db_host'],
      :db_slaves => node.dna['db_slaves'],
      :app_name => app_name
    )
  end

  cookbook_file "/data/#{app_name}/shared/config/env.custom" do
    source "env.custom"
    owner node["owner_name"]
    group node["owner_name"]
    mode 0644
    backup 0
    not_if { FileTest.exists?("/data/#{app_name}/shared/config/env.custom") }
  end

  # This block ensures that if we switch the app server stack
  # for a node app, the alternate conf style is cleared out.
  # .conf vs .tcp_conf
  (possible_exts -= [mode_hash[:ext]]).each do |ext|
    file "/data/nginx/servers/#{app_name}.#{ext}" do
      action :delete
    end
    file "/data/nginx/servers/#{app_name}.ssl.#{ext}" do
      action :delete
    end
    file "/data/nginx/servers/#{app_name}/custom.#{ext}" do
      action :delete
    end
    file "/data/nginx/servers/#{app_name}/custom.ssl.#{ext}" do
      action :delete
    end

    # Can be removed when no one is on nodejs-v2 stack
    file "/data/nginx/servers/#{app_name}.custom.#{ext}" do
      action :delete
    end
    # Can be removed when no one is on nodejs-v2 stack
    file "/data/nginx/servers/#{app_name}.custom.ssl.#{ext}" do
      action :delete
    end
  end

  managed_template "/data/nginx/servers/#{app_name}.conf" do
    owner node["owner_name"]
    group node["owner_name"]
    mode 0644
    source "server.#{mode_hash[:ext]}.erb"
    variables({
      :application => app,
      :port => app_port,
      :http_bind_port => 8081,
      :server_names => app.vhosts.first.domain_name.empty? ? [] : [app.vhosts.first.domain_name],
      :app_name => app_name
    })
    notifies :restart, resources(:service => "nginx"), :delayed
  end

  # Can be removed when no one is on nodejs-v2 stack
  file "/data/nginx/servers/#{app_name}.custom.#{mode_hash[:ext]}" do
    action :delete
  end

  file "/data/nginx/servers/#{app_name}/custom.#{mode_hash[:ext]}" do
    action :touch
    owner app_user
    group app_user
    mode 0644
  end

  unless node.engineyard.environment["stack_name"] == "node_pm2"

    ey_cloud_report "god" do
      message "configuring god to monitor #{app_name}"
    end

    template "/engineyard/bin/app_#{app_name}" do
      source "app_control.sh.erb"
      owner node["owner_name"]
      group node["owner_name"]
      backup 0
      mode 0755
      variables(
        :user => node['owner_name'],
        :framework_env => node.engineyard.environment['framework_env'],
        :home => "/home/#{app_user}",
        :app_name => app_name
      )
    end

    include_recipe 'god'

    directory "/etc/god/#{app_name}" do
      action :create
      recursive true
    end

    worker_memory_size = app.metadata(:worker_memory_size, 350)

    app_config = "/etc/god/#{app_name}/node.rb"
    managed_template app_config  do
      owner node["owner_name"]
      group node["owner_name"]
      mode 0644
      source "node.god.erb"
      backup 0
      variables(
        :app_name => app_name,
        :owner => node["owner_name"],
        :port => app_port,
        :framework_env => node.engineyard.environment['framework_env'],
        :db_user => app_user,
        :db_password => app_password,
        :db_host => node.dna['db_host'],
        :db_slaves => node.dna['db_slaves'],
        :memory_limit => worker_memory_size
      )
    end

    template "/data/#{app_name}/shared/bin/load_god_config" do
      source "load_god_config.erb"
      owner node["owner_name"]
      group node["owner_name"]
      backup 0
      mode 0755
    end

  end

  # if there is an ssl vhost
  if app.https?

    # Can be removed when no one is on nodejs-v2 stack
    file "/data/nginx/servers/#{app_name}.custom.ssl.#{mode_hash[:ext]}" do
      action :delete
    end

    file "/data/nginx/servers/#{app_name}/custom.ssl.#{mode_hash[:ext]}" do
      action :touch
      owner app_user
      group app_user
      mode 0644
    end

    template "/data/nginx/ssl/#{app_name}.key" do
      owner node["owner_name"]
      group node["owner_name"]
      mode 0644
      source "sslkey.erb"
      variables(
        :key => app[:vhosts][1][:key]
      )
      backup 0
      notifies :restart, resources(:service => "nginx"), :delayed
    end

    template "/data/nginx/ssl/#{app_name}.crt" do
      owner node["owner_name"]
      group node["owner_name"]
      mode 0644
      source "sslcrt.erb"
      variables(
        :crt => app[:vhosts][1][:crt],
        :chain => app[:vhosts][1][:chain]
      )
      backup 0
      notifies :restart, resources(:service => "nginx"), :delayed
    end

    managed_template "/data/nginx/servers/#{app_name}.ssl.conf" do
      owner node["owner_name"]
      group node["owner_name"]
      source "ssl.#{mode_hash[:ext]}.erb"
      mode 0644
      variables({
        :application  => app,
        :app_name     => app_name,
        :port         => app_port,
        :https_bind_port => 8082,
        :server_names => app[:vhosts][1][:name].empty? ? [] : [app[:vhosts][1][:name]],
      })
      notifies :restart, resources(:service => "nginx"), :delayed
    end
  else
    # nginx recipes don't take care of .tcp_conf
    # they do take care of .conf
    execute "ensure-no-old-ssl-tcp-vhosts-for-#{app.name}" do
      command %Q{
        rm -f /data/nginx/servers/#{app.name}.ssl.tcp_conf;true
      }
    end
  end

  template "/data/#{app_name}/shared/bin/build_node_app_environment" do
    source "build_node_app_environment.erb"
    owner node["owner_name"]
    group node["owner_name"]
    backup 0
    mode 0755
    variables :app_name => app_name
  end

end

ey_cloud_report "nginx" do
  message "reloading Nginx"
end

%w{ /var/tmp/nginx /var/tmp/nginx/client }.each do |dir|
  directory dir do
    owner node["owner_name"]
    group node["owner_name"]
    mode 0775
    recursive true
    action :create
  end
end

node.engineyard.apps.each_with_index do |app, app_index|
  allowed = ['node::standard', 'node::tcp']
  next if (app.recipes & allowed).size == 0
  app_name = app.name

  ey_cloud_report "node" do
    message "restarting Node.js app #{app_name}"
  end

  execute "reload-god-#{app_name}" do
    command "god load /etc/god/#{app_name}/node.rb"
    action :nothing
  end

  execute "restart-app-#{app_name}" do
    command "/engineyard/bin/app_#{app_name} restart"
    action :nothing
  end

  file "/data/#{app_name}/shared/no-websockets.txt" do
    if app.recipes.include?('node::tcp')
      action :touch
    else
      action :delete
    end
  end
end
