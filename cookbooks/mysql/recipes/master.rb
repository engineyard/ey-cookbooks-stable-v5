ey_cloud_report "mysql" do
  message "processing mysql"
end

include_recipe "mysql::install"

ey_cloud_report "mysql" do
  message "processing mysql"
end

directory "/db/mysql" do
  owner "mysql"
  group "mysql"
  mode 0755
  recursive true
end

handle_mysql_d

directory node['mysql']['logbase'] do
  owner "mysql"
  group "mysql"
  mode 0755
  recursive true
end

link "/usr/bin/mysql_install_db" do
  to "/usr/share/mysql/scripts/mysql_install_db"
  owner 'root'
  group 'root'
  only_if { ! File.exists?("/usr/bin/mysql_install_db") and File.exists?("/usr/share/mysql/scripts/mysql_install_db") }

end

execute "do-init-mysql" do
  command %Q{
    mysql_install_db --basedir=/usr/
  }
  not_if { File.directory?("#{node['mysql']['datadir']}/mysql")  }
  only_if { ['5.5', '5.6'].include?(node['mysql']['short_version']) }
end

execute "do-init-mysql" do
  command %Q{
    mysqld --initialize-insecure --user=mysql
  }
  not_if { ['5.5', '5.6'].include?(node['mysql']['short_version']) or File.directory?("#{node['mysql']['datadir']}/mysql") }
end

include_recipe "mysql::startup"

execute "set-root-mysql-pass" do
  command %Q{
    /usr/bin/mysqladmin -u root password '#{node.engineyard.environment['db_admin_password']}' || /usr/bin/mysqladmin -u root --password='' password '#{node.engineyard.environment['db_admin_password']}'; true
  }
end

include_recipe "mysql::cleanup" if node['mysql']['short_version'] == '5.6' # MySQL 5.7 doesn't include extra users/databases by default

include_recipe "mysql::setup_app_users_dbs"

include_recipe "ey-backup::mysql"
