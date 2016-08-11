#
# Cookbook Name:: ntp
# Recipe:: default
#
# Copyright 2011, Engine Yard, Inc.
#
# All rights reserved - Do Not Redistribute
#

# Install the required package.

package "net-misc/ntp" do
  action :install
  version at_least_version(node['ntp']['version'])
end

# We're using the default for now, but copy over
# the existing one in case we ever want to change
# anything.
servers = get_ntp_server_for_region.to_a

template "/etc/ntp.conf" do
  owner 'root'
  group 'root'
  mode 0644
  source "ntp.conf.erb"
  variables({ 
    :servers => servers,
    :driftfile => "/var/lib/ntp/ntp.drift",
  })
  not_if "test -f /etc/keep.ntp.conf"
end

# By default, ntpd is started with the -g option, which allows it to
# make large clock adjustments. We don't want to do this, as it may
# cause trouble in running applications if the clock jumps around.
cookbook_file "/etc/conf.d/ntpd" do
  owner 'root'
  group 'root'
  mode 0644
  source "ntpd"
end

service "ntpd" do
  action :enable
  supports :status => true, :restart => true, :start => true, :stop => true
  subscribes :restart, 'package[net-misc/ntp]'
  subscribes :restart, 'template[/etc/ntp.conf]'
end

# Script to check stale ntp endpoints -- cron for this is in ntp::cronjobs,
# which gets loaded after cron recipe clears all existing cron jobs

template "/engineyard/bin/ey-ntp-check" do
  owner 'root'
  group 'root'
  mode 0555
  source "ey-ntp-check.erb"
end
