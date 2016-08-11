use_inline_resources
# Cookbook:: newrelic
# Provider:: default

include NewrelicHelpers
include PhpHelpers

def why_run_supported?
  true
end

action :install do
  case new_resource.run_type
  when "rpm"
    if ruby_app?
      # Nothing to see here. Customer adds newrelic_rpm gem to application
    elsif php_app?
      install_php_rpm
      configure_php_rpm
    end
  when "sysmond"
    install_server_monitoring
  end
  new_resource.updated_by_last_action true
end

private

def ruby_app?
  ['rails2', 'rails3', 'rails4', 'ruby'].include? new_resource.app_type
end

def php_app?
  new_resource.app_type == 'php'
end


def install_php_rpm
  directory "/opt/php_rpm" do
    owner 'root'
    group 'root'
    mode 0755
    action :create
    recursive true
  end

  remote_file "/opt/php_rpm/newrelic-php5-#{node.dna['newrelic']['php_rpm_version']}-linux.tar.gz" do
    source "http://download.newrelic.com/php_agent/archive/#{node.dna['newrelic']['php_rpm_version']}/newrelic-php5-#{node.dna['newrelic']['php_rpm_version']}-linux.tar.gz"
    action :create_if_missing
  end

  # Install newrelic PHP as 'root' user using silent install
  bash "install_newrelic_php" do
    user 'root'
    cwd '/opt/php_rpm/'
    code <<-EOH
      export NR_INSTALL_SILENT='true'
      export NR_INSTALL_KEY="#{newrelic_license_key}"
      gzip -dc newrelic-php5-#{node.dna['newrelic']['php_rpm_version']}-linux.tar.gz | tar xf -
      cd newrelic-php5-#{node.dna['newrelic']['php_rpm_version']}-linux
      ./newrelic-install install
    EOH
    action :run
  end
end

def configure_php_rpm
  # Write custom newrelic.ini information
  template "/etc/php/cli-php5.6/ext-active/newrelic.ini" do
    owner "root"
    group "root"
    mode 0644
    backup 0
    source "newrelic.ini.erb"
    variables(
      :app_name    => "#{node.engineyard.environment['name']} / #{new_resource.app_name}",
      :license_key => newrelic_license_key)
  end

  template "/etc/php/fpm-php5.6/ext-active/newrelic.ini" do
    owner "root"
    group "root"
    mode 0644
    backup 0
    source "newrelic.ini.erb"
    variables(
      :app_name    => "#{node.engineyard.environment['name']} / #{new_resource.app_name}",
      :license_key => newrelic_license_key)
  end

  # Write newrelic.cfg information
  template "/etc/newrelic/newrelic.cfg" do
    owner "root"
    group "root"
    mode 0644
    backup 0
    source "newrelic.cfg.erb"
    variables(
      :license_key => newrelic_license_key
    )
  end

  # Set up newrelic per application
  #node.dna[:applications].each do |app, data|
  #  file = Chef::Util::FileEdit.new("/data/#{app}/shared/config/fpm-pool.conf")
  #  file.insert_line_if_no_match("/php_value[newrelic.appname] = \"#{app_name}\"/", "php_value[newrelic.appname] = \"#{app_name}\"")
  #  file.write_file
  #end

  # Add newrelic-daemon to monit
  template "/etc/monit.d/newrelic-daemon.monitrc" do
    owner "root"
    group "root"
    mode 0644
    source "newrelic-daemon.monitrc.erb"
  end

  # cookbooks/php/libraries/php_helpers.rb
  #restart_fpm
  execute 'monit restart all -g php-fpm' do
    action :run
  end

  service "nginx" do
    action :restart
  end

  execute "monit reload" do
    action :nothing
    subscribes :run, 'template[/etc/monit.d/newrelic-daemon.monitrc]', :immediately
    notifies :run, 'execute[restart newrelic-daemon]', :delayed
  end

  execute "restart newrelic-daemon" do
    action :nothing
    command "sleep 10s && monit restart newrelic-daemon || true"
  end
end

def install_server_monitoring
  enable_package "sys-apps/newrelic-sysmond" do
    version node.dna['newrelic']['sysmond_version']
  end

  package "sys-apps/newrelic-sysmond" do
    action :upgrade
    version node.dna['newrelic']['sysmond_version']
    notifies :run, 'execute[restart nrsysmond]', :delayed
  end

  template "/etc/newrelic/nrsysmond.cfg" do
    source "nrsysmond.cfg.erb"
    owner 'root'
    group 'root'
    mode 0644
    backup 0
    variables(:key => newrelic_license_key)
  end

  template "/etc/monit.d/nrsysmond.monitrc" do
    owner "root"
    group "root"
    mode 0644
    backup 0
    source "nrsysmond.monitrc.erb"
    variables(:hostname => new_resource.hostname)
  end

  directory "/var/log/newrelic" do
    action :create
    recursive true
    owner 'root'
    group 'root'
  end

 execute "monit reload" do
    action :nothing
    subscribes :run, 'template[/etc/monit.d/nrsysmond.monitrc]', :immediately
    notifies :run, 'execute[restart nrsysmond]', :delayed
  end

  execute "restart nrsysmond" do
    action :nothing
    command "sleep 3s && monit restart nrsysmond || true"
  end

end
