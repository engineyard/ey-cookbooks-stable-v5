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
  body "export PGUSER='#{node.engineyard.environment['db_admin_username']}'\nexport PGDATABASE=postgres"
  not_if "grep 'PGDATABASE' /root/.bash_login"
end

# cleanup PGHOST entries if set, this was a bug introduced by stable-v5-3.0.33 (October 2017)
  # these wouldn't have updated on a replica promotion or a db master hostname/ip change
  # better way to approach these would be to write a .ey_login and then source it from .bash_login (to be addressed in v6)
execute "remove PGHOST entries if present" do
  command "sed -i '/^export PGHOST=.*/d' /root/.bash_login"
end

cookbook_file "/root/.psqlrc" do
  source 'psqlrc'
  owner 'root'
  group 'root'
  mode '0600'
  action :create_if_missing
end

include_recipe 'ey-backup::postgres'
