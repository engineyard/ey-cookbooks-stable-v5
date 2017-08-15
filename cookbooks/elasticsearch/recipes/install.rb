ES = node['elasticsearch']

if ES['is_elasticsearch_instance']
  user "elasticsearch" do
    uid 61021
    gid "nogroup"
  end

  # Update JAVA as the Java on the AMI can sometimes crash
  #
  Chef::Log.info "Updating Java JDK to #{ES['java_version']}"
  enable_package ES['java_package_name'] do
    version ES['java_version']
    unmask true
  end

  # Forcing 'install' because if lower version packages are installed
  # then 'upgrade' installs the desired version every time it runs.
  package ES['java_package_name'] do
    version ES['java_version']
    action :install
  end

  execute "Set the default Java version to #{ES['java_version']}" do
    command "eselect java-vm set system #{ES['java_eselect_version']}"
    action :run
  end

  directory "/opt/elasticsearch-#{ES['version']}" do
    owner "elasticsearch"
    group "nogroup"
    mode 0755
  end

  ["/var/log/elasticsearch", "/var/lib/elasticsearch", "/var/run/elasticsearch"].each do |dir|
    directory dir do
      owner "elasticsearch"
      group "nogroup"
      mode 0755
    end
  end

  bash "unzip elasticsearch" do
    cwd ES['tmp_dir']
    code %(unzip #{ES['tmp_dir']}/elasticsearch-#{ES['version']}.zip)
    not_if { File.directory? "#{ES['tmp_dir']}/elasticsearch-#{ES['version']}" }
  end

  bash "copy elasticsearch root" do
    user "elasticsearch"
    cwd ES['tmp_dir']
    code %(cp -r #{ES['tmp_dir']}/elasticsearch-#{ES['version']}/* /opt/elasticsearch-#{ES['version']})
    not_if { File.exists? "/opt/elasticsearch-#{ES['version']}/lib" }
  end

  directory "/opt/elasticsearch-#{ES['version']}/plugins" do
    owner "elasticsearch"
    group "nogroup"
    mode 0755
  end

  link "/opt/elasticsearch" do
    to "/opt/elasticsearch-#{ES['version']}"
    owner "elasticsearch"
    group "nogroup"
    mode 0755
  end

  directory ES['home'] do
    owner "elasticsearch"
    group "nogroup"
    mode 0755
  end

  # Fix file permissions on data dir in case we're upgrading from ES 1.x
  execute "set-permissions-data-dir" do
    command "chown -R elasticsearch:nogroup #{ES['home']}/*"
    user "root"
    action :run
    only_if "[[ -f #{ES['home']}/* ]]"
    not_if "stat -c %U #{ES['home']}/* |grep elasticsearch"
  end

  # Fix file permissions on log dir in case we're upgrading from ES 1.x
  execute "set-permissions-log-dir" do
    command "chown -R elasticsearch:nogroup /var/log/elasticsearch/*"
    user "root"
    action :run
    only_if "ls -1 /var/log/elasticsearch/ | wc -l"
    only_if "stat -c %U /var/log/elasticsearch/*log* |grep -v elasticsearch"
  end

  directory "/data/elasticsearch-#{ES['version']}/data" do
    owner "elasticsearch"
    group "nogroup"
    mode 0755
    action :create
    recursive true
  end

  if File.new("/proc/mounts").readlines.join.match(/\/usr\/lib[0-9]*\/elasticsearch-#{ES['version']}\/data/)
    Chef::Log.info("Elastic search bind already complete")
  else
    mount "/data/elasticsearch-#{ES['version']}/data" do
      device ES['home']
      fstype "none"
      options "bind,rw"
      action :mount
    end
  end

  if ES['version'].match(/^2/)
    template "/opt/elasticsearch-#{ES['version']}/config/logging.yml" do
      source "logging.yml.erb"
      mode 0644
    end
  end

  directory "/usr/share/elasticsearch" do
    owner "elasticsearch"
    group "nogroup"
    mode 0755
  end

  if Gem::Version.new(ES['version']) < Gem::Version.new('5.0.0')
    elasticsearch_classpath = "$ES_HOME/lib/elasticsearch-#{ES['version']}.jar:$ES_HOME/lib/*"
  else
    elasticsearch_classpath = "$ES_HOME/lib/*"
  end
  template "/usr/share/elasticsearch/elasticsearch.in.sh" do
    source "elasticsearch.in.sh.erb"
    mode 0644
    backup 0
    variables(
      :elasticsearch_classpath => elasticsearch_classpath
    )
  end

  # Create the jvm.options file
  template "/opt/elasticsearch/config/jvm.options" do
    cookbook "custom-elasticsearch"
    source "jvm.options.erb"
    mode 0644
    backup 0
    variables(
      :Xms => ES['jvm_options']['Xms'],
      :Xmx => ES['jvm_options']['Xmx'],
      :Xss => ES['jvm_options']['Xss']
    )
  end

  # Add log rotation for the elasticsearch logs
  cookbook_file "/etc/logrotate.d/elasticsearch" do
    source "elasticsearch.logrotate"
    owner "root"
    group "root"
    mode "0644"
    backup 0
  end

  template "/etc/monit.d/elasticsearch_#{ES['clustername']}.monitrc" do
    source "elasticsearch.monitrc.erb"
    owner "elasticsearch"
    group "nogroup"
    backup 0
    mode 0644
    variables(:owner => "elasticsearch")
  end

  # Tell monit to just reload, if elasticsearch is not running start it.  If it is monit will do nothing.
  execute "monit reload" do
    command "monit reload"
  end
end

owner_name = node['dna']['users'].first['username']
# This portion of the recipe should run on all instances in your environment.  We are going to drop elasticsearch.yml for you so you can parse it and provide the instances to your application.
if ['solo','app_master','app','util'].include?(node['dna']['instance_role'])
  elasticsearch_hosts = []
  node['dna']['utility_instances'].each do |instance|
    if instance['name'].include?("elasticsearch_")
      elasticsearch_hosts << "#{elasticsearch['hostname']}:9200"
    end
  end

  node['dna']['applications'].each do |app_name, data|
    template "/data/#{app_name}/shared/config/elasticsearch.yml" do
      owner owner_name
      group owner_name
      mode 0660
      source "es.yml.erb"
      backup 0
      variables(:yaml_file => {
        node['dna']['environment']['framework_env'] => {
          :hosts => elasticsearch_hosts} })
    end
  end
end
