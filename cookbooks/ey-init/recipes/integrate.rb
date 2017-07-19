# Custom recipes must be run when instances are added/removed.
include_recipe 'ey-custom::before-main'

# Do a quick run
case node.dna[:instance_role]
when 'app', 'app_master'
  include_recipe 'ey-monitor'
  include_recipe 'haproxy'
when 'util'
when /^db/
  if node.engineyard.environment['db_stack_name'][/^postgres/]
    # Adding/removing an instance may change where the backup is run
    include_recipe 'ey-backup::postgres'
  end
end
include_recipe "ssh_keys" # CC-691 - update ssh whitelist after takeovers

# Custom recipes must be run when instances are added/removed.
include_recipe 'ey-custom::after-main'
