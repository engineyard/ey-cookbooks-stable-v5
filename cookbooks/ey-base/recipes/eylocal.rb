include_recipe "ey-application"
include_recipe "deploy-keys"
include_recipe "cron"
case node.engineyard.environment['db_stack_name']
when /postgres/
  include_recipe "postgresql::default"
when /mysql/
  include_recipe "mysql"
  include_recipe "mysql::master"
  include_recipe "mysql::user_my.cnf"
  include_recipe "mysql::monitoring"
when "no_db"
  #no-op
else
  raise "I don't know how to provide databases for #{node.engineyard.environment['db_stack_name']}!"
end
include_recipe "app-logs"
include_recipe "memcached"
include_recipe "newrelic"
include_recipe "deploy"
include_recipe "deploy::restart"
include_recipe "db_admin_tools"
