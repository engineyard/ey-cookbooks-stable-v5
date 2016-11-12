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


bash 'eselect php and restart via monit' do
  code <<-EOH
    eselect php set fpm php#{node["php"]["minor_version"]}
    EOH
  not_if "php-fpm -v | grep PHP | grep #{node['php']['version']}" 
  notifies :run, 'execute[monit_restart_fpm]'
end


execute 'monit_restart_fpm' do
  command "sudo monit restart php-fpm"
  action :nothing
end




# get all applications with type PHP
apps = node.dna['applications'].select{ |app, data| data['recipes'].detect{ |r| r == 'php' } }
# collect just the app names
app_names = apps.collect{ |app, data| app }

# generate global fpm config
template "/etc/php-fpm.conf" do
  owner node["owner_name"]
  group node["owner_name"]
  mode "0644"
  source "fpm-global.conf.erb"
  variables({
    :apps => app_names
  })
#  notifies :restart, resources(:service => "php-fpm"), :delayed
end

# Can't access get_fpm_coount inside block
app_fpm_count = (get_fpm_count / node.dna['applications'].size)
app_fpm_count = 1 unless app_fpm_count >= 1

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

  mc_hostnames = node.engineyard.environment.instances.map{|i| i['private_hostname'] if i['role'][/^app|solo/]}.compact.map {|i| "#{i}:11211"}

  template "/data/#{app_name}/shared/config/fpm-pool.conf" do
    owner node["owner_name"]
    group node["owner_name"]
    mode 0644
    source "fpm-pool.conf.erb"
    variables({
      :app_name => app_name,
      :php_env => node.dna['environment']['framework_env'],
      :user => node["owner_name"],
      :dbuser => node["owner_name"],
      :dbpass => node.engineyard.environment.ssh_password,
      :dbhost => node.dna['db_host'],
      :dbreplicas => node.dna['db_slaves'].join(':'),
      :max_children => app_fpm_count,
      :memcache_hostnames => mc_hostnames.join(',')
    })

  end
end

# Report to Cloud dashboard
#ey_cloud_report "processing php" do
#  message "processing php - monitoring"
#end

# Create global init.d file
# We are unable to start and stop each app individually
cookbook_file "/engineyard/bin/php-fpm" do
  owner node["owner_name"]
  group node["owner_name"]
  mode 0777
  source "init.d-php-fpm.sh"
  backup 0
end

# Delete any existing init.d file if it's not a symlink
cookbook_file "/etc/init.d/php-fpm" do
  action :delete
  backup 0

  not_if "test -h /etc/init.d/php-fpm"
end

# Create a symlink under init.d
link "/etc/init.d/php-fpm" do
  to "/engineyard/bin/php-fpm"
end

# get all applications with type PHP
apps = node.dna['applications'].select{ |app, data| data['recipes'].detect{ |r| r == 'php' } }
# collect just the app names
app_names = apps.collect{ |app, data| app }

app_names.each do |app|
  # create symlinks for each app, too. Required for deploy.
  link "/engineyard/bin/app_#{app}" do
    to "/engineyard/bin/php-fpm"
  end

  # Change ownership of app slowlog if set to root
  check_fpm_log_owner(app)
end

# Create monitrc file (all apps) and restart monit
template "/etc/monit.d/php-fpm.monitrc" do
  owner node["owner_name"]
  group node["owner_name"]
  mode 0600
  source "php-fpm.monitrc.erb"
  variables(
    :apps => app_names,
    :user => node["owner_name"]
  )
  backup 0

  notifies :run, 'execute[restart-monit]'
end

# cookbooks/php/libraries/php_helpers.rb
restart_fpm
