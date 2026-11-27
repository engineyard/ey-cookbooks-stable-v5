class Chef::Recipe
  include PhpHelpers
end

# Report to Cloud dashboard
ey_cloud_report "processing php#{node["php"]["minor_version"]}" do
  message "processing php - php-fpm #{node["php"]["minor_version"]}"
end

# Overwrite default php config
cookbook_file "/etc/php/fpm-php#{node["php"]["minor_version"]}/php.ini" do
  source "php.ini"
  owner "root"
  group "root"
  mode "0755"
  backup 0
end

# create directory for fpm logs
directory "/var/log/engineyard/php-fpm" do
  owner node["owner_name"]
  group node["owner_name"]
  mode "0755"
  action :create
end

# create error log for fpm
file "/var/log/engineyard/php-fpm/error.log" do
  owner node["owner_name"]
  group node["owner_name"]
  mode "0644"
  action :create_if_missing
end

# create directory for unix socket(s)
directory "/var/run/engineyard" do
  owner node["owner_name"]
  group node["owner_name"]
  recursive true
  mode "0755"
  action :create
end

# stopping common php-fpm service if it's running
execute 'stop obsolete php-fpm service' do
  command "/usr/bin/monit stop php-fpm"
  only_if "/usr/bin/monit status php-fpm"
end

# deleting obsolete service files
execute 'delete old init scripts' do
  command "rm -f /etc/monit.d/php-fpm.monitrc && rm -rf /etc/init.d/php-fpm && rm -f /engineyard/bin/php-fpm"
  only_if "test -f /etc/monit.d/php-fpm.monitrc"
end

monit_service 'monit_reload_config' do
  action :nothing
end

bash 'eselect php and restart via monit' do
  code <<-EOH
    eselect php set fpm php#{node["php"]["minor_version"]}
    EOH
  not_if "php-fpm -v | grep PHP | grep #{node['php']['version']}"
  notifies :restartall, 'monit_service[monit_reload_config]'
end

# get all applications with type PHP
apps = node.dna['applications'].select{ |app, data| data['recipes'].detect{ |r| r == 'php' } }
# collect just the app names
app_names = apps.collect{ |app, data| app }

# Can't access get_fpm_coount inside block
app_fpm_count = (get_fpm_count / node.dna['applications'].size)
app_fpm_count = 1 unless app_fpm_count >= 1
mc_hostnames = node.engineyard.environment.instances.map{|i| i['private_hostname'] if i['role'][/^app|solo/]}.compact.map {|i| "#{i}:11211"}

# generate an fpm pool for each php app
app_names.each do |app_name|
  cookbook_file "/data/#{app_name}/shared/config/env.custom" do
    source "env.custom"
    owner node.engineyard.environment.ssh_username
    group node.engineyard.environment.ssh_username
    mode 0755
    backup 0
    not_if { FileTest.exists?("/data/#{app_name}/shared/config/env.custom") }
  end

  # Create init.d for each php-fpm application
  # To be able to start and stop each application separately
  template "/engineyard/bin/php-fpm_#{app_name}" do
    owner node["owner_name"]
    group node["owner_name"]
    mode 0777
    source "php-fpm-openrc.erb"
    variables(
      :app_name => app_name,
      :user => node["owner_name"],
      :group => node["owner_name"]
    )
  end

  # Delete any existing init.d file if it's not a symlink
  cookbook_file "/etc/init.d/php-fpm_#{app_name}" do
    action :delete
    backup 0
    not_if "test -h /etc/init.d/php-fpm_#{app_name}"
  end

  # Create a symlink under init.d
  link "/etc/init.d/php-fpm_#{app_name}" do
    to "/engineyard/bin/php-fpm_#{app_name}"
  end

  # create symlinks for each app too. Required for deploy.
  link "/engineyard/bin/app_#{app_name}" do
    to "/engineyard/bin/php-fpm_#{app_name}"
  end

  # Create monitrc file for the application and restart monit
  template "/etc/monit.d/php-fpm_#{app_name}.monitrc" do
    owner node["owner_name"]
    group node["owner_name"]
    mode 0600
    source "php-fpm.monitrc.erb"
    variables(
      :app_name => app_name
    )
    backup 0
    notifies :reload, "monit_service[monit_reload_config]", :immediately
  end

  # generate global fpm config
  template "/etc/php/php-fpm_#{app_name}.conf" do
    owner node["owner_name"]
    group node["owner_name"]
    mode "0644"
    source "fpm-global.conf.erb"
    variables({
      :app_name => app_name
    })
    notifies :restart, "monit_service[php-fpm_#{app_name}]", :delayed
  end

  # generate global fpm config
  template "/etc/php/php-fpm_#{app_name}.conf" do
    owner node["owner_name"]
    group node["owner_name"]
    mode "0644"
    source "fpm-global.conf.erb"
    variables({
      :app_name => app_name
    })
    notifies :restart, "monit_service[php-fpm_#{app_name}]", :delayed
  end

  template "/data/#{app_name}/shared/config/fpm-pool.conf" do
    owner node["owner_name"]
    group node["owner_name"]
    mode 0644
    source "fpm-pool.conf.erb"
    variables({
      :app_name => app_name,
      :php_env => node.dna['environment']['framework_env'],
      :user => node["owner_name"],
      :dbuser => node.engineyard.environment.apps.detect {|app| app[:name] == app_name}.database_username,
      :dbpass => node.engineyard.environment.apps.detect {|app| app[:name] == app_name}.database_password,
      :dbhost => node.dna['db_host'],
      :dbreplicas => node.dna['db_slaves'].join(':'),
      :max_children => app_fpm_count,
      :memcache_hostnames => mc_hostnames.join(',')
    })
    notifies :restart, "monit_service[php-fpm_#{app_name}]", :delayed
  end

  monit_service "php-fpm_#{app_name}" do
    service_name "php-fpm_#{app_name}"
    action :start
  end
  
  # Change ownership of app slowlog if set to root
  check_fpm_log_owner(app_name)

end
