include_recipe "cron"
case node.engineyard.environment['db_stack_name']
when /postgres/
  include_recipe "postgresql::default"
when /mysql/
  include_recipe "mysql::client"
when "no_db"
  #no-op
end

include_recipe "ey-application"
include_recipe "app-logs"
include_recipe "deploy-keys"
include_recipe "collectd"
include_recipe "newrelic"
include_recipe "deploy"
include_recipe "db_admin_tools"
