#
# Cookbook Name:: ssmtp
# Recipe:: default
#
# Copyright 2009, Engine Yard, Inc.
#
# All rights reserved - Do Not Redistribute

package "mail-mta/ssmtp" do
  action :upgrade
  version "2.64-r2"
end

execute "fix the permissions" do
  owner = node["owner_name"]
  command %Q{
    chmod +x /usr/sbin/ssmtp
    chown #{owner}:#{owner} /etc/ssmtp/ssmtp.conf
  }
  only_if { File.exists?("/etc/ssmtp/ssmtp.conf") && File.exists?("/usr/sbin/ssmtp") }
end
