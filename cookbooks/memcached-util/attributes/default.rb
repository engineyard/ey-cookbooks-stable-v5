#
# Cookbook Name:: memcached
# Attrbutes:: default
#

default['memcached'].tap do |memcached|

  # Memcached will be installed on a solo or a utility instance named 'memcached'
  #memcached['is_memcached_instance'] =
  #  (node['dna']['instance_role'] == 'solo') ||
  #  (node['dna']['instance_role'] == 'util' && node['dna']['name'] == 'memcached')
end
