# Installs extra packages
#
# Timezone tables
tz_tables_loaded = %Q{mysql -u #{node.engineyard.environment['db_admin_username']} -p'#{node.engineyard.environment['db_admin_password']}' -N -e 'SELECT COUNT(*)>0 FROM mysql.time_zone' | grep 1}

execute "load-tz-tables" do
  command "mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u #{node.engineyard.environment['db_admin_username']} -p'#{node.engineyard.environment['db_admin_password']}' mysql"
  not_if tz_tables_loaded
end
