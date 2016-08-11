template "/tmp/mysql-cleanup.sql" do
  mysql_hostname = node['ec2'] ? node['ec2']['local_hostname'].split(".").first : `hostname`.split(".").first
  mysql_hostname_variant = `hostname`

  owner 'root'
  group 'root'
  mode 0644
  source "cleanup.sql.erb"
  variables({
    :dbpass => node['owner_pass'],
    :user_hosts => [
      ['',    'localhost'],
      ['',     mysql_hostname],
      ['root','127.0.0.1'],
      ['root', mysql_hostname],
      ['root', '%'],
      ['root', mysql_hostname_variant],
      ['', mysql_hostname_variant],
      ['root', '::1'],
    ]
  })
end

execute "remove-database-file-for-mysql-cleanup" do
  command %Q{
    rm /tmp/mysql-cleanup.sql
  }
  action :nothing
end

execute "create-database-for-mysql-cleanup" do
  command %Q{
    export MYSQL_PWD=#{node['owner_pass']}; mysql -u root < /tmp/mysql-cleanup.sql
  }
  notifies :run, 'execute[remove-database-file-for-mysql-cleanup]'
end
