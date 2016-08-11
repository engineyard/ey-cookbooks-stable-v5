#
# Cookbook Name:: monit
# Recipe:: default
#
# Copyright 2008, Engine Yard, Inc.
#
# All rights reserved - Do Not Redistribute
#

monit_version = node.engineyard.metadata("monit_ebuild_version", node['monit']['version'])
Chef::Log.info "Monit Version: #{monit_version}"

ey_cloud_report "monit" do
  message "processing monit"
end

enable_package 'app-admin/monit' do
  version monit_version
end

package 'app-admin/monit' do
  version monit_version
  action :install
end

template "/etc/monitrc" do
  owner "root"
  group "root"
  mode 0700
  source 'monitrc.erb'
  action :create
end

bash "migrate-monit.d-dir" do
  code %Q{
    mv /etc/monit.d /data/
    ln -nfs /data/monit.d /etc/monit.d
  }

  not_if 'file /etc/monit.d | grep "symbolic link"'
end

directory "/data/monit.d" do
  owner "root"
  group "root"
  mode 0755
end

template "/etc/monit.d/alerts.monitrc" do
  owner "root"
  group "root"
  mode 0700
  source 'alerts.monitrc.erb'
  action :create_if_missing
end

runlevel 'monit' do
  action :delete
end

service 'monit' do
  action :stop 
  only_if '/etc/init.d/monit status'
end

template "/usr/local/bin/monit" do
  owner "root"
  group "root"
  mode 0700
  source 'monit.erb'
  variables({
      :nofile => 16384
  })
  action :create_if_missing
end

execute "touch monitrc" do
  command "touch /etc/monit.d/ey.monitrc"
end

inittab "mo" do
  command "/usr/local/bin/monit -Ic /etc/monitrc"
end

inittab "m0" do
  command "/usr/local/bin/monit -Ic /etc/monitrc stop all"
  action :wait
  runlevel 0, 6
end

execute "restart-monit" do
  apps = node.dna['applications'].map{|app, data| data['type'] }
  cmd = []
  apps.each do |app|
    case app
    when 'rails'
      cmd << "pkill -9 mongrel_rails"
    when 'rack'
      cmd << "pkill -9 rackup"
    when 'merb'
      cmd << "ps axx | grep merb | grep -v grep| cut -c1-6| xargs kill -9"
    end
  end
  cmd.uniq!
  command %Q{ #{cmd.join(' && ')} || [[ $? == 1 ]]}
  command %Q{ pkill -9 monit || [[ $? == 1 ]]}
  action :nothing
end

execute "monit quit" do
  action :nothing
  notifies :restart, 'service[monit]'
end

