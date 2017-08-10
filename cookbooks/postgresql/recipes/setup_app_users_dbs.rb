
admin_username = node.engineyard.environment['db_admin_username']
admin_password = node.engineyard.environment['db_admin_password']


node.engineyard.apps.each do |app|
  execute "create db user #{app.database_username}" do
    command  %{psql -U #{admin_username} -h #{node.dna['db_host']} -c "CREATE USER #{app.database_username} with ENCRYPTED PASSWORD '#{app.database_password}' createdb" postgres}
    not_if %{psql -U #{admin_username} -h #{node.dna['db_host']} -c "select * from pg_roles" postgres | grep #{app.database_username}}
  end

  if db_host_is_rds?
    execute "grant db user role #{app.database_username} to admin user #{admin_username}" do
      command %{psql -U #{admin_username} -h #{node.dna['db_host']} -c "GRANT #{app.database_username} TO #{admin_username} WITH ADMIN OPTION;" postgres}
    end
  end

  execute "create database for #{app.database_name} owned by #{app.database_username}" do
    command %{PGPASSWORD="#{app.database_password}" createdb -U #{app.database_username} -h #{node.dna['db_host']} #{app.database_name}}
    not_if %{psql -U #{admin_username}  -h #{node.dna['db_host']} -t -c "select datname from pg_database where datname = '#{app.database_name}';" postgres | grep #{app.database_name}}
  end

  execute "alter public schema of db #{app.database_name} owner to #{app.database_username}" do
    command %{psql -U #{admin_username}  -h #{node.dna['db_host']} -c "ALTER SCHEMA public OWNER TO #{app.database_username}" #{app.database_name}}
    not_if %{psql -U #{admin_username}  -h #{node.dna['db_host']} -c "select pg_is_in_recovery()" | grep t}
  end
end
