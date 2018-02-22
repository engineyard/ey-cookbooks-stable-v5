package "dev-db/mytop" do
  version '1.6-r5'
  action :install
end

template "/root/.mytop" do
  owner 'root'
  mode 0600
  variables ({
    :username => node.engineyard.environment['db_admin_username'],
    :password => node.engineyard.environment['db_admin_password'],
    :database => 'mysql',
    :host => node['dna']['instance_role'][/^(db|solo)/] ? 'localhost' : node['dna']['db_host'],
  })
  source "mytop.erb"
end

template "/home/#{node["owner_name"]}/.mytop" do
  owner node["owner_name"]
  mode 0600
  variables ({
    :username => node.engineyard.apps.first.database_username,
    :password => node.engineyard.apps.first.database_password,
    :database => node.engineyard.apps.map {|app| app.database_name }.first,
    :host => node['dna']['instance_role'][/^(db|solo)/] ? 'localhost' : node['dna']['db_host'],
  })
  source "mytop.erb"
end

