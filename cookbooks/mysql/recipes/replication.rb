template "/tmp/root_perms.sql" do
  owner 'root'
  group 'root'
  mode 0644
  source "default_perms.sql.erb"
  variables({
    :dbpass => node['owner_pass'],
  })
end

execute "remove-default-permissions-file" do
  command %Q{
    rm /tmp/root_perms.sql
  }
  action :nothing
end

execute "set-default-permisions" do
  command %Q{
    export MYSQL_PWD=#{node['owner_pass']}; mysql -u root < /tmp/root_perms.sql
  }
  notifies :run, 'execute[remove-default-permissions-file]'
end
