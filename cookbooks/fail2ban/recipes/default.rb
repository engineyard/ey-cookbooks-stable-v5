#
# Cookbook Name:: fail2ban
# Recipe:: default
#
#
# install package

ey_cloud_report "Fail2Ban" do
  message "Installing Fail2Ban"
end

enable_package "net-analyzer/fail2ban" do
  version node['fail2ban']['version']
end

package 'net-analyzer/fail2ban' do
  version node['fail2ban']['version']
  action :install
end

template "/etc/fail2ban/fail2ban.conf" do
  owner 'root'
  group 'root'
  mode 0644
  source "fail2ban.conf-#{node['fail2ban']['version']}.erb"
  variables({
    loglevel: node['fail2ban']['loglevel'],
    logtarget: node['fail2ban']['logtarget'],
    socket: node['fail2ban']['socket'],
    pidfile: node['fail2ban']['pidfile']
  })
end

include_recipe "fail2ban::service"

include_recipe "fail2ban::jails"
