#
# Cookbook Name:: memcached
# Attrbutes:: default
#

default['memcached'].tap do |memcached|

  # Install memcached on a utility instance named 'memcached'
  memcached['install_type'] = 'NAMED_UTILS'
  memcached['utility_name'] = 'memcached'

  # Install memcached on all app instances
  #memcached['install_type'] = 'ALL_APP_INSTANCES'

  # Amount of memory in MB to be used by memcached
  memcached['memusage'] = 1024

  # Additional memcached configuration options
  # Default: no additional options
  memcached['misc_opts'] = ''
  # Increase the growth factor.
  # Try this if you allocated more memory to memcached
  # and you're seeing lots of partially-filled slabs
  # memcached['misc_opts'] = '-f 1.5'
  # See https://blog.engineyard.com/2015/fine-tuning-memcached
end
