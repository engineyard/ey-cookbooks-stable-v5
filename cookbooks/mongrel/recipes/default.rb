#
# Cookbook Name:: mongrel
# Recipe:: default
#
# Copyright 2008, Engine Yard, Inc.
#
# All rights reserved - Do Not Redistribute
#


ey_cloud_report "mongrel" do
  message "processing mongrel"
end

node.dna['mongrel']['gems'].each do |gem, version|
  gem_package gem do
    version version
    action :install
  end
end

directory "/var/log/engineyard/mongrel" do
  owner node["owner_name"]
  group node["owner_name"]
  mode 0755
end

directory "/var/run/mongrel" do
  owner node["owner_name"]
  group node["owner_name"]
  mode 0755
end

execute "cleanup monit.d dir" do
  command "rm /etc/monit.d/mongrel*.monitrc
           rm /etc/monit.d/mongrel_merb*.monitrc
           rm /etc/monit.d/mongrel_rack*.monitrc; true"
end

base_port=5000
node.engineyard.apps.each_with_index do |app,index|

  directory "/var/run/mongrel/#{app.name}" do
    owner node["owner_name"]
    group node["owner_name"]
    mode 0755
  end

  mongrel_service = []
# find_app_service(app, "mongrel") # No longer in DNA, use Metadata
  mongrel_base_port = base_port + (index * 200)
# (mongrel_service[:mongrel_base_port].to_i + (index * 1000))
  mongrel_instance_count = (get_pool_size / node.dna['applications'].size)
  mongrel_instance_count = 1 if mongrel_instance_count == 0
  default_memory_limit = "150"

  # :app_memory_limit is no longer used but is checked here and overridden when :worker_memory_size is available
  depreciated_memory_limit = metadata_app_get_with_default(app.name, :app_memory_limit, default_memory_limit)
  # See https://support.cloud.engineyard.com/entries/23852283-Worker-Allocation-on-Engine-Yard-Cloud for more details
  memory_limit = metadata_app_get_with_default(app.name, :worker_memory_size, depreciated_memory_limit)

  case app.app_type
  when "rails"

    monitrc("mongrel", :mongrel_base_port => mongrel_base_port,
            :mongrel_instance_count => mongrel_instance_count,
            :mongrel_mem_limit => memory_limit,
            :app_name => app.name,
            :user => node["owner_name"])

    template "/engineyard/bin/app_#{app.name}" do
      source "app_control.rails.erb"
      mode 0755
      owner node.engineyard.environment.ssh_username
      group node.engineyard.environment.ssh_username
      backup 0
      variables({
        :app_name      => app.name,
        :framework_env => node.dna['environment']['framework_env'],
        :low_port      => mongrel_base_port,
        :high_port     => mongrel_base_port + mongrel_instance_count - 1,
        :checkpid_body => Erubis::Eruby.new(File.read(File.dirname(__FILE__) + '/../templates/default/checkpid.sh.erb')).evaluate(:pid_prefix => "/var/run/mongrel/#{app.name}/mongrel"),
        :home          => "/home/#{node.engineyard.environment.ssh_username}"
      })
    end

  when "merb"
    directory "/var/log/engineyard/merb" do
      owner node["owner_name"]
      group node["owner_name"]
      mode 0755
    end
    directory "/var/log/engineyard/merb/#{app.name}" do
      owner node["owner_name"]
      group node["owner_name"]
      mode 0755
    end
    monitrc("mongrel_merb", :mongrel_base_port => mongrel_base_port,
                            :mongrel_instance_count => mongrel_instance_count,
                            :mongrel_mem_limit => memory_limit,
                            :app_name => app.name,
                            :framework_env => node.dna['environment']['framework_env'],
                            :user => node["owner_name"])

    template "/engineyard/bin/app_#{app.name}" do
      source "app_control.merb.erb"
      mode 0755
      owner node.engineyard.environment.ssh_username
      group node.engineyard.environment.ssh_username
      backup 0
      variables({
        :app_name      => app.name,
        :framework_env => node.dna['environment']['framework_env'],
        :ports         => mongrel_instance_count,
        :low_port      => mongrel_base_port,
        :high_port     => mongrel_base_port + mongrel_instance_count - 1,
        :checkpid_body => Erubis::Eruby.new(File.read(File.dirname(__FILE__) + '/../templates/default/checkpid.sh.erb')).evaluate(:pid_prefix => "/var/log/engineyard/#{app.name}/#{app.name}-#{node.dna['environment']['framework_env']}-merb"),
        :home          => "/home/#{node.engineyard.environment.ssh_username}",
        :user          => node.engineyard.environment.ssh_username,
      })
    end
  when 'rack'
    monitrc("mongrel_rack", :mongrel_base_port => mongrel_base_port,
                            :mongrel_instance_count => mongrel_instance_count,
                            :mongrel_mem_limit => memory_limit,
                            :app_name => app.name,
                            :user => node["owner_name"])

    remote_file "/engineyard/bin/rackup_stop" do
      owner "root"
      group "root"
      mode 0777
      source "rackup_stop"
      action :create
    end

    template "/engineyard/bin/app_#{app.name}" do
      source "app_control.rack.erb"
      mode 0755
      owner node.engineyard.environment.ssh_username
      group node.engineyard.environment.ssh_username
      backup 0
      variables({
        :app_name      => app.name,
        :framework_env => node.dna['environment']['framework_env'],
        :low_port      => mongrel_base_port,
        :high_port     => mongrel_base_port + mongrel_instance_count - 1,
        :checkpid_body => Erubis::Eruby.new(File.read(File.dirname(__FILE__) + '/../templates/default/checkpid.sh.erb')).evaluate(:pid_prefix => "/var/run/mongrel/#{app.name}/mongrel"),
        :home          => "/home/#{node.engineyard.environment.ssh_username}"
      })
    end

    include_recipe "mongrel::monitoring"

  end

  template "/data/#{app.name}/shared/config/mongrel_cluster.yml" do
    owner node["owner_name"]
    group node["owner_name"]
    mode 0644
    variables({
      :mongrel_base_port => mongrel_base_port,
      :mongrel_instance_count => mongrel_instance_count,
      :app_name => app.name
    })
    source "mongrel_cluster.yml.erb"
    notifies :run, "execute[restart-monit]"
  end

  # cleanup extra mongrel workers
  bash "cleanup extra mongrel workers" do
    code <<-EOH
      for pidfile in /var/run/mongrel/#{app.name}/mongrel.*.pid; do
        [[ $(echo "${pidfile}" | egrep -o '([0-9]+)' | tail -n 1) -gt #{mongrel_base_port + mongrel_instance_count - 1} ]] && kill -6 $(cat $pidfile) || true
      done
    EOH
  end
end

include_recipe "mongrel::cleanup_passenger"
