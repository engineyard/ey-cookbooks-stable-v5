template "/root/.pgpass" do
  backup 0
  mode 0600
  owner 'root'
  group 'root'
  source 'pgpass.erb'
  variables({
    :dbpass => node.engineyard.environment['db_admin_password']
  })
end

execute "touch ~/.bash_login" do
  action :run
end

update_file "add_PGUSER_to_root_bash_login" do
  path "/root/.bash_login"
  body "export PGUSER='#{node.engineyard.environment['db_admin_username']}'\nexport PGHOST='#{node.dna['db_host']}'\nexport PGDATABASE=postgres"
  not_if "grep 'PGDATABASE' /root/.bash_login"
end

cookbook_file "/root/.psqlrc" do
  source 'psqlrc'
  owner 'root'
  group 'root'
  mode '0600'
  action :create_if_missing
end

include_recipe 'ey-backup::postgres'
