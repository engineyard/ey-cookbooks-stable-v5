
# Sets a default schedule of Midnight system time Sunday for a vacuum
if node[:dna][:instance_role][/^db_master|solo/] && node[:dna][:engineyard][:environment][:db_stack_name][/^postgres/]
  cron "manual_vacuumdb" do
    minute  node['postgresql_maintenance']['vacuumdb_cron_minute']
    hour    node['postgresql_maintenance']['vacuumdb_cron_hour']
    day     node['postgresql_maintenance']['vacuumdb_cron_day']
    month   node['postgresql_maintenance']['vacuumdb_cron_month']
    weekday node['postgresql_maintenance']['vacuumdb_cron_weekday']
    command node['postgresql_maintenance']['vacuumdb_command']
  end
end
