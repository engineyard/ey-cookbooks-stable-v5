case node['dna']['engineyard']['environment']['db_stack_name']
when "postgres9_4"
  default['postgresql']['latest_version'] = '9.4.12'
  default['postgresql']['short_version'] = '9.4'
when "postgres9_5"
  default['postgresql']['latest_version'] = '9.5.7'
  default['postgresql']['short_version'] = '9.5'
when "postgres9_6"
  default['postgresql']['latest_version'] = '9.6.3'
  default['postgresql']['short_version'] = '9.6'
end
default['postgresql']['datadir'] = "/db/postgresql/#{node['postgresql']['short_version']}/data/"
default['postgresql']['dbroot'] = '/db/postgresql/'
default['postgresql']['owner'] = 'postgres'
