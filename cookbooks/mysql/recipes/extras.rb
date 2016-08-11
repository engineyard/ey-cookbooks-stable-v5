# Installs extra packages
#
# Timezone tables
tz_tables_loaded = %Q{mysql -u root -N -e 'SELECT COUNT(*)>0 FROM mysql.time_zone' | grep 1}

execute "load-tz-tables" do
  command "mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root mysql"
  not_if tz_tables_loaded
end
