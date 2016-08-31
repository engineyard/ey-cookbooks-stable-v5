include_recipe "ebs::default"

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
end

include_recipe "mysql::startup"

execute "set-root-mysql-pass" do
  command %Q{
    /usr/bin/mysqladmin -u root password '#{node['owner_pass']}'; true
  }
end

include_recipe "mysql::cleanup"

node.engineyard.environment['apps'].each do |app|

  dbhost = (node.dna['db_host'] == 'localhost' ? 'localhost' : '%')

  template "/tmp/create.#{app['name']}.sql" do
    owner 'root'
    group 'root'
    mode 0644
    source "create.sql.erb"
    variables({
      :dbuser => node["owner_name"],
      :dbpass => node['owner_pass'],
      :dbname => app['database_name'],
      :dbhost => dbhost,
    })
  end

  execute "remove-database-file-for-#{app['name']}" do
    command %Q{
      rm /tmp/create.#{app['name']}.sql
    }
    action :nothing
  end

  execute "create-database-for-#{app['name']}" do
    command %Q{
      export MYSQL_PWD=#{node['owner_pass']}; mysql -u root < /tmp/create.#{app['name']}.sql
    }
    notifies :run, "execute[remove-database-file-for-#{app['name']}]"
  end
end

include_recipe "ey-backup::mysql"
