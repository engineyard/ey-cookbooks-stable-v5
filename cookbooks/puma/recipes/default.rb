#
# Cookbook Name:: puma
# Recipe:: default
#
# Copyright 2011, Engine Yard, Inc.
#
# All rights reserved - Do Not Redistribute
#

ey_cloud_report "puma" do
  message "processing puma"
end

service "nginx" do
  action :nothing
  supports :status => false, :restart => true
end

base_port     = 8200
stepping      = 200
app_base_port = base_port
ports = []

# Total workers are based on CPU counts on target instance, with a minimum of 1 worker per app
workers = [(1.0*node['cpu']['total']/node.dna['applications'].size).round,1].max

node.engineyard.apps.each_with_index do |app,index|
  app_base_port = base_port + ( stepping * index )
  app_path      = "/data/#{app.name}"
  deploy_file   = "#{app_path}/current/REVISION"
  log_file      = "#{app_path}/shared/log/puma.log"
  ssh_username  = node.engineyard.environment.ssh_username
  framework_env = node.dna['environment']['framework_env']
  restart_resource = "restart-puma-#{app.name}"
  solo = node.dna['instance_role'] == 'solo'

  execute restart_resource do
    command "monit restart #{app.name}"
    action :nothing
  end

  #node['nginx'][:version] = node.dna[:passenger3][:nginx_version]
  ports = (app_base_port...(app_base_port+workers)).to_a

  app.vhosts.each do |vhost|
    vhost app.name do
      dna_vhost vhost
      cookbook 'puma'
      upstream_ports ports
    end
  end

  directory "/var/run/engineyard/#{app.name}" do
    owner ssh_username
    group ssh_username
    mode 0755
    recursive true
  end

  template "/data/#{app.name}/shared/config/env" do
    source "env.erb"
    backup 0
    owner ssh_username
    group ssh_username
    mode 0755
    cookbook 'puma'
    variables(:app_name      => app.name,
              :user          => ssh_username,
              :deploy_file   => deploy_file,
              :framework_env => framework_env,
              :baseport      => app_base_port,
              :workers       => workers,
              :threads       => '' # Uses default of 0:16 - May want to change this in the future for concurrent(rbx/jruby) vs non-concurrent(mri) rubies
             )
  end

  file "/data/#{app.name}/shared/config/env.custom" do
    owner ssh_username
    group ssh_username
    mode 0644
    action :create_if_missing
  end

  template "/engineyard/bin/app_#{app.name}" do
    source  'app_control.erb'
    owner   ssh_username
    group   ssh_username
    mode    0755
    backup  0
    cookbook  'puma'

    variables(:app_name      => app.name,
              :app_dir       => "#{app_path}/current",
              :deploy_file   => deploy_file,
              :shared_path   => "#{app_path}/shared",
              :ports         => ports,
              :framework_env => framework_env,
              :jruby         => node.engineyard.environment.jruby?)

  end

  logrotate "puma_#{app.name}" do
    files log_file
    copy_then_truncate
  end

  # :app_memory_limit is no longer used but is checked here and overridden when :worker_memory_size is available
  depreciated_memory_limit = metadata_app_get_with_default(app.name, :app_memory_limit, "255.0")
  # See https://support.cloud.engineyard.com/entries/23852283-Worker-Allocation-on-Engine-Yard-Cloud for more details
  memory_limit = metadata_app_get_with_default(app.name, :worker_memory_size, depreciated_memory_limit)

  managed_template "/etc/monit.d/puma_#{app.name}.monitrc" do
    source "puma.monitrc.erb"
    owner "root"
    group "root"
    mode 0666
    backup 0
    cookbook  'puma'
    variables(:app => app.name,
              :app_memory_limit => memory_limit,
              :username => ssh_username,
              :ports => ports)
  end

  execute restart_resource do
    command "monit restart #{app.name}"
    action :nothing
  end

end

include_recipe "puma::cleanup_passenger"
