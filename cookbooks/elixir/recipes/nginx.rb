include_recipe "nginx"

node.engineyard.apps.each_with_index do |app, index|

  nginx_http_port = 8081
  nginx_https_port = 8082
  base_port = node['elixir']['port'].to_i
  stepping = 200
  app_base_port = base_port + ( stepping * index )


  template "/data/nginx/servers/#{app.name}.conf" do
    owner ssh_username
    group ssh_username
    mode 0644
    source "nginx_app.conf.erb"
    cookbook "elixir"
    variables({
      :vhost => app.vhosts.first,
      :port => nginx_http_port,
      :upstream_port => app_base_port,
      :framework_env => framework_env
    })
    notifies :restart, resources(:service => "nginx"), :delayed
  end
end
