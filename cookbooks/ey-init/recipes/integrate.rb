# Do a quick run
case node.dna[:instance_role]
when 'app', 'app_master'
  include_recipe 'ey-monitor'
  include_recipe 'haproxy'
when 'util'
when /^db/
  if node.engineyard.environment['db_stack_name'][/^postgres/]
    include_recipe 'ey-backup::postgres'
  end
  is_db_master = ['db_master'].include?(node.dna['instance_role'])
  include_recipe "db-ssl::setup" if is_db_master
end
include_recipe "ssh_keys" # CC-691 - update ssh whitelist after takeovers
include_recipe "ey-hosts"
