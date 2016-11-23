#
# Cookbook Name:: thinking_sphinx_3
# Attrbutes:: default
#

default['sphinx'] = {
  'utility_name' => 'sphinx',

  # The version of sphinx to install
  # Default: 2.1.9
  'version' => '2.1.9',
  
  # Applications that use sphinx
  # Default: all applications on the environment
  'applications' => node['dna']['applications'].map{|app_name, data| app_name},
  
  # Index frequency. How often the indexer cron job runs
  # Default: 15 (minutes)
  'frequency' => 15
}

# True if the recipe should run on the instance
# Default: true on a solo instance or a utility instance named 'sphinx'
default['sphinx']['is_thinking_sphinx_instance'] = node['dna']['instance_role'] == 'util' && node['dna']['name'] == default['sphinx']['utility_name']

# Sphinx host
# Default: hostname of the 'sphinx' utility instance
util = node['dna']['engineyard']['environment']['instances'].find{|i| i[:name].to_s == default['sphinx']['utility_name']}
Chef::Log.info "SPHINX INSTANCE: #{util.inspect}"

default['sphinx']['host'] = util ? util['private_hostname'] : '127.0.0.1'
Chef::Log.info "SPHINX HOST: #{default['sphinx']['host']}"

