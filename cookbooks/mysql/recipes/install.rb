lock_db_version = node.engineyard.environment.components.find_all {|e| e['key'] == 'lock_db_version'}.first['value'] if node.engineyard.environment.lock_db_version?

lock_version_file = '/db/.lock_db_version'
db_running = %x{mysql -N -e "select 1;" 2> /dev/null}.strip == '1'

known_versions = {
  # Note: mysql 5.5 is a limited access feature on this stack; use 5.6 or higher if possible.
  'dev-db/mysql' => ['5.5.49'],
  'dev-db/percona-server' => ['5.6.28.76.1', '5.6.29.76.2-r1', '5.6.32.78.1', '5.6.35.81.0', '5.7.13.6', '5.7.14.8', '5.7.17.13']
}

if node.dna['instance_role'][/^(db|solo)/]
  execute "dropping lock version file" do
    command "echo $(mysql --version | grep -E -o 'Distrib [0-9]+\.[0-9]+\.[0-9]+' | awk '{print $NF}') > #{lock_version_file}"
    action :run
    only_if { lock_db_version and not File.exists?(lock_version_file) and db_running }
  end

  execute "remove lock version file" do
    command "rm #{lock_version_file}"
    only_if { not lock_db_version and File.exists?(lock_version_file) }
  end
end

unmask_package "virtual/mysql" do
  version node['mysql']['virtual']
  unmaskfile "mysql"
end

enable_package "virtual/mysql" do
  version node['mysql']['virtual']
end

enable_package "virtual/libmysqlclient" do
  version '20'
  only_if { node['mysql']['short_version'] == "5.7" }
end

ey_cloud_report "mysql" do
  message "Handling MySQL Install"
end

ruby_block "getting full version and doing install" do    # ~FC014
  # FoodCritic note: Ignore as this is used in one place and it is clearer described here
  block do
    if File.exists?(lock_version_file)
      install_version  = %x{cat #{lock_version_file}}.strip
    else
      install_version = node['mysql']['latest_version']
    end
    package_name, package_version = nil
    known_versions.each do |label, versions|
      if match = versions.detect {|v| v =~ /^#{install_version}/}
        package_name = label
        package_version = match
        break
      end
    end

    if package_version.nil?
      Chef::Log.info "Chef does not know about MySQL version #{install_version}"
      exit(1)
    else
      Chef::Log.info "--- lock_db_version = #{lock_db_version} -- Installing: #{package_version}"
      keyword_file = '/etc/portage/package.keywords/local'
      unmask_file = '/etc/portage/package.unmask/mysql'
      %x{ grep -q "=#{package_name}-#{package_version}" #{keyword_file} || echo "=#{package_name}-#{package_version}" >> #{keyword_file}}
      %x{ grep -q "=#{package_name}-#{package_version}" #{unmask_file} || echo "=#{package_name}-#{package_version}" >> #{unmask_file}}
      %x{ grep -q "=dev-util/cmake-2.6.2" #{keyword_file} || echo "=dev-util/cmake-2.6.2" >> #{keyword_file}}
      %x{ emerge -g --noreplace =#{package_name}-#{package_version}}
    end
  end
end

include_recipe "mysql::relink_mysql" unless node['mysql']['short_version'] == "5.6"

if node.dna['instance_role'][/^db/]    # ~FC023
  # FoodCritic note: Ignore becuase this custom resource doesn't offer only_if
  sysctl "Set vm.swappiness" do
    variables 'vm.swappiness' => '15'
  end
end
