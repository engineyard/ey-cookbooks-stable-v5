#
# Cookbook Name:: app-logs
# Recipe:: default
#
# Copyright 2010, Engine Yard, Inc.
#
# All rights reserved - Do Not Redistribute
#

(node.dna['applications'] || []).each do |app_name, app_info|
  directory "/var/log/engineyard/apps/#{app_name}" do
    owner node["owner_name"]
    group node["owner_name"]
    mode 0755
    recursive true
  end

  link "/data/#{app_name}/shared/log" do
    to "/var/log/engineyard/apps/#{app_name}"
    owner node["owner_name"]
    group node["owner_name"]
  end
end

logrotate "application-logs" do
  files "/var/log/engineyard/apps/*/*.log"
  copy_then_truncate true
end

(node.dna['removed_applications'] || []).each do |dead_app|
  execute "remove-logs-for-#{dead_app}" do
    command %Q{
      rm -rf /var/log/engineyard/apps/#{dead_app}
    }
  end
end
