#
# Cookbook Name:: redis
# Recipe:: default
#

redis_utility_name = node['redis']['utility_name'] || 'redis'

if ['util'].include?(node['dna']['instance_role'])
  if node['dna']['name'] == redis_utility_name

    include_recipe "sysctl::tune_large_db"

    sysctl "Enable Overcommit Memory" do
      variables 'vm.overcommit_memory' => 1
    end

    enable_package "dev-db/redis" do
      version node['redis']['version']
      override_hardmask true
      unmask :true
    end

    package "dev-db/redis" do
      version node['redis']['version']
      action :upgrade
    end

    directory node['redis']['basedir'] do
      owner 'redis'
      group 'redis'
      mode 0755
      recursive true
      action :create
    end

    template "/etc/redis_util.conf" do
      owner 'root'
      group 'root'
      mode 0644
      source "redis.conf.erb"
      variables({
        'pidfile' => node['redis']['pidfile'],
        'basedir' => node['redis']['basedir'],
        'basename' => node['redis']['basename'],
        'logfile' => node['redis']['logfile'],
        'loglevel' => node['redis']['loglevel'],
        'port'  => node['redis']['bindport'],
        'unixsocket' => node['redis']['unixsocket'],
        'saveperiod' => node['redis']['saveperiod'],
        'timeout' => node['redis']['timeout'],
        'databases' => node['redis']['databases'],
        'rdbcompression' => node['redis']['rdbcompression'],
        'hz' => node['redis']['hz']
      })
    end

    # redis-server is in /usr/bin on stable-v2, /usr/sbin for stable-v4
    if Chef::VERSION[/^0.6/]
      bin_path = "/usr/bin/redis-server"
    else
      bin_path = "/usr/sbin/redis-server"
    end

    template "/data/monit.d/redis_util.monitrc" do
      owner 'root'
      group 'root'
      mode 0644
      source "redis.monitrc.erb"
      variables({
        'profile' => '1',
        'configfile' => '/etc/redis_util.conf',
        'pidfile' => node['redis']['pidfile'],
        'logfile' => node['redis']['basename'],
        'port' => node['redis']['bindport'],
        'bin_path' => bin_path
      })
    end

    execute "monit reload" do
      action :run
    end
  end
end

if ['solo', 'app', 'app_master', 'util'].include?(node['dna']['instance_role'])
  instances = node['dna']['engineyard']['environment']['instances']
  redis_instance = (node['dna']['instance_role'][/solo/] && instances.length == 1) ? instances[0] : instances.find{|i| i['name'] == redis_utility_name}

  if redis_instance
    ip_address = `ping -c 1 #{redis_instance['private_hostname']} | awk 'NR==1{gsub(/\\(|\\)/,"",$3); print $3}'`.chomp
    host_mapping = "#{ip_address} redis-instance"

    execute "Remove existing redis-instance mapping from /etc/hosts" do
      command "sudo sed -i '/redis-instance/d' /etc/hosts"
      action :run
    end

    execute "Add redis-instance mapping to /etc/hosts" do
      command "sudo echo #{host_mapping} >> /etc/hosts"
      action :run
    end

    node['dna']['applications'].each do |app, data|
      template "/data/#{app}/shared/config/redis.yml"do
        source 'redis.yml.erb'
        owner node['owner_name']
        group node['owner_name']
        mode 0655
        backup 0
        variables({
          'environment' => node['dna']['engineyard']['environment']['framework_env'],
          'hostname' => redis_instance['private_hostname']
        })
      end
    end
  end
end
