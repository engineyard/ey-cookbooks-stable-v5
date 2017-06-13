package "dev-db/mytop" do
  version '1.6-r5'
  action :install
end

template "/root/.mytop" do
  owner 'root'
  mode 0600
  variables ({
    :username => 'root',
    :password => node['owner_pass'],
    :database => 'mysql',
    :host => node.dna['instance_role'][/^(db|solo)/] ? '127.0.0.1' : node.dna['db_host'],
  })
  source "mytop.erb"
end

template "/home/#{node["owner_name"]}/.mytop" do
  owner node["owner_name"]
  mode 0600
  variables ({
    :username => node["owner_name"],
    :password => node['owner_pass'],
    :database => node.engineyard.apps.map {|app| app.database_name }.first, 
    :host => node.dna['instance_role'][/^(db|solo)/] ? '127.0.0.1' : node.dna['db_host'],
  })
  source "mytop.erb"
end

