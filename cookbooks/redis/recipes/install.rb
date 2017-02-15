#
# Cookbook Name:: redis
# Recipe:: default
#
# Download and install redis if one of the following is true:
# - the redis base directory does not exist
# - force_upgrade == true
#
# Create the redis basedir if the redis basedir does not exist
#

redis_version = node['redis']['version']
redis_config_file_version = redis_version[0..2]
redis_download_url = node['redis']['download_url']
redis_base_directory = node['redis']['basedir']

run_installer = !FileTest.exists?(redis_base_directory) || node['redis']['force_upgrade']

if node['redis']['is_redis_instance']

  sysctl "Enable Overcommit Memory" do
    variables 'vm.overcommit_memory' => 1
  end

  if run_installer
    if node['redis']['install_from_source']
      include_recipe 'redis::install_from_source'
    else
      include_recipe 'redis::install_from_package'
    end

    directory redis_base_directory do
      owner 'redis'
      group 'redis'
      mode 0755
      recursive true
      action :create
    end
  end

  redis_config_variables = {
    'basedir' => node['redis']['basedir'],
    'basename' => node['redis']['basename'],
    'logfile' => node['redis']['logfile'],
    'loglevel' => node['redis']['loglevel'],
    'port'  => node['redis']['port'],
    'saveperiod' => node['redis']['saveperiod'],
    'timeout' => node['redis']['timeout'],
    'databases' => node['redis']['databases'],
    'rdbcompression' => node['redis']['rdbcompression'],
    'rdb_filename' => node['redis']['rdb_filename'],
    'hz' => node['redis']['hz']
  }
  if node['dna']['name'] == node['redis']['slave_name']
    redis_config_template = "redis-#{redis_config_file_version}-slave.conf.erb"

    # TODO: Move this to a function
    instances = node['dna']['engineyard']['environment']['instances']
    redis_master_instance = instances.find{|i| i['name'] == node['redis']['utility_name']}

    redis_config_variables['master_ip'] = redis_master_instance['private_hostname']
  else
    redis_config_template = "redis-#{redis_config_file_version}.conf.erb"
  end

  template "/etc/redis.conf" do
    owner 'root'
    group 'root'
    mode 0644
    source redis_config_template
    variables redis_config_variables
  end

  if node['redis']['install_from_source']
    bin_path = '/usr/local/bin'
  else
    bin_path = '/usr/sbin'
  end
  template "/data/monit.d/redis.monitrc" do
    owner 'root'
    group 'root'
    mode 0644
    source "redis.monitrc.erb"
    variables({
      'configfile' => '/etc/redis.conf',
      'pidfile' => node['redis']['pidfile'],
      'logfile' => node['redis']['basename'],
      'port' => node['redis']['port'],
      'bin_path' => bin_path
    })
  end

  execute "monit reload" do
    action :run
  end
end
