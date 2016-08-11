lock_major_version = %x{[[ -f "/db/.lock_db_version" ]] && grep -E -o '^[0-9]+\.[0-9]+' /db/.lock_db_version }
db_stack = lock_major_version == '' ? attribute.dna['engineyard']['environment']['db_stack_name'] :  "mysql#{lock_major_version.gsub(/\./, '_').strip}"

default['latest_version_56'] = '5.6.29'

case db_stack
when 'mysql5_6', 'aurora5_6'
  default['mysql']['latest_version'] = node['latest_version_56']
  default['mysql']['virtual'] = "5.6"
  default['mysql']['short_version'] = '5.6'
  default['mysql']['logbase'] = '/db/mysql/5.6/log/'
  default['mysql']['datadir'] =  '/db/mysql/5.6/data/'

# Keeping this split out in case it makes sense to add a MariaDB stack to AppCloud
when  'mariadb10_0'
  default['mysql']['latest_version'] = node['latest_version_56']
  default['mysql']['virtual'] = "5.6"
  default['mysql']['short_version'] = '5.6'
  # If we add a stack later these paths will have to be changed, along with several other changes.
  default['mysql']['logbase'] = '/db/mysql/5.6/log/'
  default['mysql']['datadir'] = '/db/mysql/5.6/data/'
end
