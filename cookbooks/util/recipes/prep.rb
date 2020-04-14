include_recipe "deploy-keys"
include_recipe "ey-cron"

#TODO: Remove this chunk to the db_master recipe
is_solo = ['solo'].include?(node.dna['instance_role'])
unless is_solo   # for solo leave the db stuff to the db cookbook
  case node.engineyard.environment['db_stack_name']
  when /^postgres\d+/, /^aurora-postgresql\d+/
    include_recipe "postgresql::default"
  when /^mysql\d+/, /^aurora\d+/, /^mariadb\d+/
    include_recipe "mysql::client"
    include_recipe "mysql::user_my.cnf"
  when "no_db"
    #no-op
  end
end


include_recipe 'app::remove'
include_recipe 'app::create'
include_recipe "app-logs"
include_recipe "deploy"
include_recipe "db_admin_tools"
