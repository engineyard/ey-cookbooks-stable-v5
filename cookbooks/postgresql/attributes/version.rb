case attribute.dna.engineyard.environment.db_stack_name
when "postgres9_4", "aurora-postgresql9_4"
  default['postgresql']['latest_version'] = '9.4.24'
  default['postgresql']['short_version'] = '9.4'
when "postgres9_5", "aurora-postgresql9_5"
  default['postgresql']['latest_version'] = '9.5.19'
  default['postgresql']['short_version'] = '9.5'
when "postgres9_6", "aurora-postgresql9_6"
  default['postgresql']['latest_version'] = '9.6.15'
  default['postgresql']['short_version'] = '9.6'
when "postgres10", "aurora-postgresql10"
  default['postgresql']['latest_version'] = '10.10'
  default['postgresql']['short_version'] = '10'
end
default['postgresql']['datadir'] = "/db/postgresql/#{node['postgresql']['short_version']}/data/"
default['postgresql']['dbroot'] = '/db/postgresql/'
default['postgresql']['owner'] = 'postgres'
