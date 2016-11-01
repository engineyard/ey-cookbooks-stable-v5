#
# Cookbook Name:: memcached
# Attrbutes:: default
#

default['memcached'].tap do |memcached|

  # Install memcached on a utility instance named 'memcached'
  #memcached['install_type'] = 'NAMED_UTILS'
  #memcached['util_name'] = 'memcached'

  # Install memcached on all app instances
  memcached['install_type'] = 'ALL_APP_INSTANCES'
end
