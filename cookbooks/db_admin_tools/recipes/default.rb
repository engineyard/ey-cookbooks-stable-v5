case  node.engineyard.environment['db_stack_name']
when /mysql/
  include_recipe 'db_admin_tools::mysql'
when /postgres/
  include_recipe 'db_admin_tools::postgres'
end
