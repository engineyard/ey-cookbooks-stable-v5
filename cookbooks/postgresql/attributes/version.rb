case attribute.dna.engineyard.environment.db_stack_name
when "postgres9_4"
  default['postgresql']['latest_version'] = "9.4.11"
  default['postgresql']['short_version'] = "9.4"
when "postgres9_5"
  default['postgresql']['latest_version'] = "9.5.6"
  default['postgresql']['short_version'] = "9.5"
end
default['postgresql']['datadir'] = "/db/postgresql/#{node['postgresql']['short_version']}/data/"
default['postgresql']['dbroot'] = '/db/postgresql/'
default['postgresql']['owner'] = 'postgres'
