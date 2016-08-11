package "dev-db/mytop" do
  version '1.6-r4'
  action :install
end

template "/root/.mytop" do
  owner 'root'
  mode 0600
  variables ({
    :username => 'root',
    :password => node['owner_pass'],
    :host => node.dna['instance_role'][/^(db|solo)/] ? 'localhost' : node.dna['db_host'],
  })
  source "mytop.erb"
end

template "/home/#{node["owner_name"]}/.mytop" do
  owner node["owner_name"]
  mode 0600
  variables ({
    :username => node["owner_name"],
    :password => node['owner_pass'],
    :host => node.dna['instance_role'][/^(db|solo)/] ? 'localhost' : node.dna['db_host'],
  })
  source "mytop.erb"
end

