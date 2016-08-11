#
# Cookbook Name:: passenger5
# Recipe:: install
#


  # Notify dashboard
  ey_cloud_report "passenger5" do
    message "Processing Passenger 5"
  end

  # Install gems required by Passenger standalone
  ruby_block "gems to install" do
    block do
      system("gem install daemon_controller rack:1.6.4 --no-ri --no-rdoc")
    end
  end

  gem_package 'passenger' do
    version node['passenger5']['version']
    action :install
  end

  # Grab version, ssh user, rails_env and port
  version       = node['passenger5']['version']
  ssh_username  = node['owner_name']
  framework_env = node.dna['environment']['framework_env']
  port          = node['passenger5']['port']

  service "nginx" do
    action :nothing
    supports :status => false, :restart => true
  end



  # Write out the advanced configuration file
  # From the Passenger Standalone documentation:
  # Please note that changes to this file only last until you reinstall or upgrade Phusion Passenger.
  # We are currently working on a mechanism for permanently editing the configuration file.
  # template "/opt/passenger-server-5.0.29/resources/templates/standalone/config.erb" do
  #   owner ssh_username
  #   group ssh_username
  #   mode 0644
  #   source "config.erb"
  #   action :create
  # end
  nginx_http_port = 8081
  nginx_https_port = 8082
  base_port = node['passenger5']['port'].to_i
  stepping = 200
  app_base_port = base_port

  node.engineyard.apps.each_with_index do |app,index|
    app_path      = "/data/#{app.name}"
    log_file      = "#{app_path}/shared/log/passenger.log"
    app_base_port = base_port + ( stepping * index )


    # Get nginx http and https ports, memory limits and worker counts.  Uses metadata if it exists.

    # :app_memory_limit is no longer used but is checked here and overridden when :worker_memory_size is available
    depreciated_memory_limit = metadata_app_get_with_default(app.name, :app_memory_limit, "255.0")
    # See https://support.cloud.engineyard.com/entries/23852283-Worker-Allocation-on-Engine-Yard-Cloud for more details
    memory_limit = metadata_app_get_with_default(app.name, :worker_memory_size, depreciated_memory_limit)
    memory_option = memory_limit ? "-l #{memory_limit}" : ""
    worker_count = get_pool_size

    # Render the http Nginx vhost
    template "/data/nginx/servers/#{app.name}.conf" do
      owner ssh_username
      group ssh_username
      mode 0644
      source "nginx_app.conf.erb"
      cookbook "passenger5"
      variables({
        :vhost => app.vhosts.first,
        :port => nginx_http_port,
        :upstream_port => app_base_port,
        :framework_env => framework_env
      })
      notifies :restart, resources(:service => "nginx"), :delayed
    end

    # Render proxy.conf
    cookbook_file "/etc/nginx/common/proxy.conf" do
      owner ssh_username
      group ssh_username
      mode 0644
      source "proxy.conf"
      action :create
      notifies :restart, resources(:service => "nginx"), :delayed
    end

    # If certificates have been added, render the https Nginx vhost and custom config
    if app.vhosts.first.https?
      file "/data/nginx/servers/#{app.name}/custom.ssl.conf" do
        action :create_if_missing
        owner node.ssh_username
        group node.ssh_username
        mode 0644
      end

      template "/data/nginx/servers/#{app.name}.ssl.conf" do
        owner node.ssh_username
        group node.ssh_username
        mode 0644
        source "nginx_app.conf.erb"
        variables({
          :vhost => app.vhosts.first,
          :ssl => true,
          :port => nginx_https_port,
          :upstream_port => app_base_port,
          :framework_env => framework_env
        })
        notifies :restart, resources(:service => "nginx"), :delayed
      end
    end

    # Render app control script, this script calls the passenger enterprise binaries using the full path
    template "/engineyard/bin/app_#{app.name}" do
      source  'app_control.erb'
      owner   ssh_username
      group   ssh_username
      mode    0755
      backup  0
      variables(:user => ssh_username,
                :app_name => app.name,
                :version  => version,
                :port     => app_base_port,
                :worker_count  => worker_count,
                :rails_env     => framework_env)
    end

    # Setup log rotate for passenger.log
    logrotate "passenger5_#{app.name}" do
      files log_file
      copy_then_truncate
    end

    # Render monitrc file to watch standalone passenger
    template "/etc/monit.d/passenger5_#{app.name}.monitrc" do
      source "passenger5.monitrc.erb"
      owner "root"
      group "root"
      mode 0666
      backup 0
      variables(:app => app.name,
                :app_memory_limit => memory_limit,
                :username => ssh_username,
                :port => app_base_port,
                :version => version)
    end

  end

  # Render passenger_monitor script
  cookbook_file "/engineyard/bin/passenger_monitor" do
    source "passenger_monitor"
    owner node['owner_name']
    group node['owner_name']
    mode "0655"
    backup 0
  end

  # Reload monit after making changes
  execute "monit-reload" do
    command "monit quit && telinit q"
  end
