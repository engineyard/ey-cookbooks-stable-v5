#
# Cookbook Name:: redis
# Recipe:: default
#
# Download and install redis if one of the following is true:
# - the redis installer directory does not exist
# - force_upgrade == true
#
# Create the redis basedir if the redis basedir does not exist
#

redis_version = node['redis']['version']
redis_config_file_version = redis_version[0..2]
redis_download_url = node['redis']['download_url']
redis_installer_directory = '/opt/redis-source'
redis_base_directory = node['redis']['basedir']

run_installer = !FileTest.exists?(redis_installer_directory) || node['redis']['force_upgrade']
setup_basedir = !FileTest.exists?(redis_base_directory) || node['redis']['force_upgrade']

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
  end

  if setup_basedir
    directory redis_base_directory do
      owner 'redis'
      group 'redis'
      mode 0755
      recursive true
      action :create
    end
  end

  template "/etc/redis.conf" do
    owner 'root'
    group 'root'
    mode 0644
    source "redis-#{redis_config_file_version}.conf.erb"
    variables({
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
    })
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
