lock_major_version = %x{[[ -f "/db/.lock_db_version" ]] && grep -E -o '^[0-9]+\.[0-9]+' /db/.lock_db_version }
db_stack = lock_major_version == '' ? node['dna']['engineyard']['environment']['db_stack_name'] :  "mysql#{lock_major_version.gsub(/\./, '_').strip}"

default['latest_version_55'] = '5.5.49'
default['latest_version_56'] = '5.6.37'
default['latest_version_57'] = '5.7.19'
major_version=''

case db_stack
when 'mysql5_5'
  # Note: mysql 5.5 is a limited access feature on this stack; use 5.6 or higher if possible.
  major_version = '5.5'
  default['mysql']['latest_version'] = node['latest_version_55']
  default['mysql']['virtual'] = "#{major_version}-r1"
  
when 'mysql5_6', 'aurora5_6', 'mariadb10_0'
  major_version = '5.6'
  default['mysql']['latest_version'] = node['latest_version_56']
  default['mysql']['virtual'] = major_version
  
when 'mysql5_7', 'aurora5_7', 'mariadb10_1'
  major_version = '5.7'
  default['mysql']['latest_version'] = node['latest_version_57']
  default['mysql']['virtual'] = major_version

end

default['mysql']['short_version'] = major_version
default['mysql']['logbase'] = "/db/mysql/#{major_version}/log/"
default['mysql']['datadir'] = "/db/mysql/#{major_version}/data/"
default['mysql']['dbroot'] = '/db/mysql/'
default['mysql']['owner'] = 'mysql'
