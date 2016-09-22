lock_major_version = %x{[[ -f "/db/.lock_db_version" ]] && grep -E -o '^[0-9]+\.[0-9]+' /db/.lock_db_version }
full_version =  %x{[[ -f "/db/.lock_db_version" ]] && grep -E -o '^[0-9]+\.[0-9]+\.[0-9]+' /db/.lock_db_version }
db_stack = lock_major_version == '' ? attribute.dna['engineyard']['environment']['db_stack_name'] :  "mysql#{lock_major_version.gsub(/\./, '_').strip}"

default['latest_version_56'] = '5.6.32'
default['latest_version_57'] = '5.7.14'
major_version=''

case db_stack
when 'mysql5_6', 'aurora5_6', 'mariadb10_0'
  default['mysql']['latest_version'] = node['latest_version_56']
  major_version = '5.6'
  
when 'mysql5_7', 'aurora5_7', 'mariadb10_1'
  default['mysql']['latest_version'] = node['latest_version_57']
  major_version = '5.7'

end

default['mysql']['full_version'] = full_version == '' ? node['mysql']['latest_version'] : full_version
default['mysql']['virtual'] = major_version
default['mysql']['short_version'] = major_version
default['mysql']['logbase'] = "/db/mysql/#{major_version}/log/"
default['mysql']['datadir'] = "/db/mysql/#{major_version}/data/"