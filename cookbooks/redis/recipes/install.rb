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
bin_path = '/usr/local/bin'

run_installer = !FileTest.exists?(redis_installer_directory) || node['redis']['force_upgrade']
setup_basedir = !FileTest.exists?(redis_base_directory) || node['redis']['force_upgrade']

if node['redis']['is_redis_instance']

  sysctl "Enable Overcommit Memory" do
    variables 'vm.overcommit_memory' => 1
  end

  if run_installer
    remote_file "/opt/redis-#{redis_version}.tar.gz" do
      source "#{redis_download_url}"
      owner node[:owner_name]
      group node[:owner_name]
      mode 0644
      backup 0
    end

    execute "unarchive Redis installer" do
      cwd "/opt"
      command "tar zxf redis-#{redis_version}.tar.gz && sync"
    end

    execute "Remove old redis-source" do
      command "rm -rf /opt/redis-source"
    end

    execute "rename /opt/redis-#{redis_version} to /opt/redis-source" do
      command "mv /opt/redis-#{redis_version} #{redis_installer_directory}"
    end

    execute "run redis-source/make install" do
      cwd redis_installer_directory
      command "make install"
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
