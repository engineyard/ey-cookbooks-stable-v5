#
# Cookbook Name:: solr
# Recipe:: default
#
# We specify what version we want below.
use_default_java = false
java_package_name = "dev-java/icedtea-bin"
java_version = node['solr']['java_version']
java_eselect_version = node['solr']['java_eselect_version']
solr_version = node['solr']['solr_version']
solr_file = "solr-#{solr_version}.tgz"
solr_url = "https://archive.apache.org/dist/lucene/solr/#{solr_version}/#{solr_file}"
core_name = node['solr']['core_name']

username = node['dna']['users'].first['username']

# Install Solr
if node['solr']['is_solr_instance']

  unless use_default_java
    Chef::Log.info "Updating Java JDK"
    enable_package java_package_name do
      version java_version
      unmask true
    end

    package java_package_name do
      version java_version
      action :upgrade
    end

    execute "Set the default Java version to #{java_eselect_version}" do
      command "eselect java-vm set system #{java_eselect_version}"
      action :run
    end
  end

  directory "/var/run/solr" do
    action :create
    owner username
    group username
    mode 0755
  end

  directory "/var/log/engineyard/solr" do
    action :create
    owner username
    group username
    mode 0755
    recursive true
  end

  template "/engineyard/bin/solr" do
    source "solr.erb"
    owner username
    group username
    mode 0755
    variables({
      :rails_env => node['dna']['environment']['framework_env']
    })
  end

  template "/etc/monit.d/solr.monitrc" do
    source "solr.monitrc.erb"
    owner username
    group username
    mode 0644
  end

  remote_file "/data/#{solr_file}" do
    source solr_url
    owner username
    group username
    mode 0644
    backup 0
    action :create_if_missing
  end

  execute "unarchive solr-to-install" do
    cwd "/data"
    command "tar zxf #{solr_file} && sync"
    not_if { FileTest.directory?("/data/solr") }
  end

  execute "rename /data/solr-#{solr_version} to /data/solr" do
    command "mv /data/solr-#{solr_version} /data/solr"
    not_if { FileTest.directory?("/data/solr") }
  end

  execute "chown solr directory" do
    command "chown #{username}:#{username} -R /data/solr"
  end

  # Installs log rotation config
  cookbook_file "/etc/logrotate.d/solr" do
    owner "root"
    group "root"
    mode 0644
    source "solr.logrotate"
    backup false
    action :create
  end

  execute "monit-reload" do
    command "monit quit && telinit q"
  end

  execute "start-solr" do
    command "sleep 3 && monit start solr"
  end

  execute "create default solr core" do
    command "sleep 30 && /data/solr/bin/solr create_core -c #{core_name}"
    user username
    not_if { FileTest.directory?("/data/solr/server/solr/#{core_name}") }
  end
end

# Create /data/appname/shared/config/solr.yml in solo, app and util instances
solr_instance = if ('solo' == node['dna']['instance_role'])
  node
else
  node['dna']['utility_instances'].find{ |instance| instance['name'] == node['solr']['solr_instance_name'] }
end

if solr_instance && ['app_master', 'app', 'solo', 'util'].include?(node['dna']['instance_role'])
  node['dna']['applications'].each do |app, data|
    template "/data/#{app}/shared/config/solr.yml" do
      source 'solr.yml.erb'
      owner username
      group username
      mode 0655
      backup 0
      variables({
        :environment => node['dna']['environment']['framework_env'],
        :hostname => solr_instance['hostname']
      })
    end
  end
end
