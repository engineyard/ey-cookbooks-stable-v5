define :nginx_vhost, :stack_config => false, :upstream_ports => [] do
  # variables
  vhost = params[:dna_vhost]
  app = vhost.app
  book = params[:cookbook]
  worker_count = params[:worker_count] || get_pool_size()
  upstream_ports = params[:upstream_ports]

  # define nginx service
  service "nginx" do
    supports :restart => true, :status => true, :reload => true
    action :nothing
  end

  # setup
  include_recipe 'nginx::setup'

  template "/data/nginx/stack.conf" do
    owner node.engineyard.environment.ssh_username
    group node.engineyard.environment.ssh_username
    mode 0644
    source "nginx_stack.conf.erb"
    cookbook book.to_s
    variables({
      :user => node.engineyard.environment.ssh_username,
      :worker_count => worker_count
    })
    notifies node['nginx'][:action], resources(:service => "nginx"), :delayed
    only_if { params[:stack_config] }
  end

  file "/data/nginx/stack.conf" do
    action :create_if_missing
    owner node.engineyard.environment.ssh_username
    group node.engineyard.environment.ssh_username
    mode 0644
  end

  directory "/data/nginx/servers/#{app.name}" do
    owner node.engineyard.environment.ssh_username
    group node.engineyard.environment.ssh_username
    mode 0775
  end

  managed_template "/data/nginx/servers/#{app.name}.rewrites" do
    owner node.engineyard.environment.ssh_username
    group node.engineyard.environment.ssh_username
    mode 0644
    source "server.rewrites.erb"
    cookbook 'nginx'
    action :create_if_missing
    notifies node['nginx'][:action], resources(:service => "nginx"), :delayed
  end

  file "/data/nginx/servers/#{app.name}/custom.conf" do
    action :create_if_missing
    owner node.engineyard.environment.ssh_username
    group node.engineyard.environment.ssh_username
    mode 0644
  end

  # HAX for SD-4650
  # Remove it when awsm stops using dnapi to generate the dna and allows configure ports

  meta = node.engineyard.apps.detect {|a| a.metadata?(:nginx_http_port) }
  nginx_http_port = ( meta and meta.metadata?(:nginx_http_port) ) || 8081

  managed_template "/data/nginx/servers/#{app.name}.conf" do
    owner node.engineyard.environment.ssh_username
    group node.engineyard.environment.ssh_username
    mode 0644
    source "nginx_app.conf.erb"
    cookbook book
    variables({
      :app_name => app.name,
      :vhost => vhost,
      :port => nginx_http_port,
      :upstream_ports => upstream_ports,
      :framework_env => node.engineyard.environment.framework_env
    })
    notifies node['nginx'][:action], resources(:service => "nginx"), :delayed
  end

  if vhost.https?
    file "/data/nginx/servers/#{app.name}/custom.ssl.conf" do
      action :create_if_missing
      owner node.engineyard.environment.ssh_username
      group node.engineyard.environment.ssh_username
      mode 0644
    end

    managed_template "/data/nginx/servers/#{app.name}.ssl.conf" do
      owner node.engineyard.environment.ssh_username
      group node.engineyard.environment.ssh_username
      mode 0644
      source "nginx_app.conf.erb"
      cookbook book
      variables({
        :app_name => app.name,
        :vhost => vhost,
        :ssl => true,
        :port => nginx_https_port,
        :upstream_ports => upstream_ports,
        :framework_env => node.engineyard.environment.framework_env
      })
      notifies node['nginx'][:action], resources(:service => "nginx"), :delayed
    end

    template "/data/nginx/ssl/#{app.name}.key" do
      owner node.engineyard.environment.ssh_username
      group node.engineyard.environment.ssh_username
      mode 0644
      source "sslkey.erb"
      cookbook 'nginx'
      backup 0
      variables({
        :key => vhost.ssl_cert['private_key']
      })
      notifies node['nginx'][:action], resources(:service => "nginx"), :delayed
    end

    template "/data/nginx/ssl/#{app.name}.crt" do
      owner node.engineyard.environment.ssh_username
      group node.engineyard.environment.ssh_username
      mode 0644
      source "sslcrt.erb"
      cookbook 'nginx'
      backup 0
      variables({
        :chain => vhost.ssl_cert['certificate_chain'],
        :crt => vhost.ssl_cert['certificate']
      })
      notifies node['nginx'][:action], resources(:service => "nginx"), :delayed
    end
  else
    # cleanup any old ssl vhosts
    file "/data/nginx/servers/#{app.name}.ssl.conf" do
      action :delete
      only_if "test -f /data/nginx/servers/#{app.name}.ssl.conf"
      notifies node['nginx'][:action], resources(:service => "nginx"), :delayed
    end
  end
end
