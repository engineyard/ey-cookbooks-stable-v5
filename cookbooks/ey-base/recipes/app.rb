include_recipe "ey-application"
include_recipe "deploy-keys"
include_recipe "ey-cron"
case node.engineyard.environment['db_stack_name']
when /postgres/
  include_recipe "postgresql::default"
when /mysql/
  include_recipe "mysql::client"
  include_recipe "mysql::user_my.cnf"
when "no_db"
  #no-op
end

include_recipe "collectd"
include_recipe "app-logs"
include_recipe "newrelic"
include_recipe "deploy"
include_recipe "deploy::restart"
include_recipe "lb"
include_recipe "db_admin_tools"
