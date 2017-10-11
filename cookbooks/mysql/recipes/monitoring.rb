ey_cloud_report "mysql monitoring" do
  message "processing mysql monitoring"
end

template "/engineyard/bin/check_mysql.sh" do
  source "check_mysql.sh.erb"
  backup 0
  owner 'mysql'
  group 'mysql'
  mode 0751
  variables({
    :dbpass => node.engineyard.environment['db_admin_password']
  })
end
