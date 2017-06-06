include_recipe 'db-ssl::setup'

cookbook_file "/engineyard/bin/mysql_start" do
  source "mysql_start"
  mode "744"
end

ey_cloud_report "report starting mysql" do
  message "starting mysql"
  not_if "/etc/init.d/mysql status"
end

execute "start-mysql" do
  sleeptime = 15      # check mysql's status every 15 seconds
  sleeplimit = 7200   # give mysql 2 hours to start (for long recovery operations)

  command "/engineyard/bin/mysql_start --password #{node.engineyard.environment.ssh_password} --check #{sleeptime} --timeout #{sleeplimit}"
  
  timeout sleeplimit

  not_if "/etc/init.d/mysql status"
end

service "mysql" do
  action :enable
end
