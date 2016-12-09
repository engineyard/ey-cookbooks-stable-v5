include_recipe "ey-cron"
case node.engineyard.environment['db_stack_name']
when /postgres/
  include_recipe "postgresql::default"
when /mysql/
  include_recipe "mysql"
  include_recipe "mysql::user_my.cnf"
  include_recipe "mysql::slave"
  include_recipe "mysql::monitoring"
when "no_db"
  #no-op
end

include_recipe "db_admin_tools"
