directory "/opt/node" do
  action :delete
  recursive true
end

available_nodejs_versions = node['nodejs']['available_versions'].sort {|x,y| Engineyard::Version.new(x) <=> Engineyard::Version.new(y)}

# Update the attributes
node.normal['nodejs']['available_versions'] = available_nodejs_versions

# Leave a .json with the node versions we provide
directory "/opt/nodejs" do
  owner 'root'
  group 'root'
  mode 0755
  recursive true
  action :create
end

managed_template "/opt/nodejs/nodejs_available_versions.json" do
  owner 'root'
  group 'root'
  source "nodejs_available_versions.json.erb"
  mode 0644
  variables({
    :nodejs  => node['nodejs']
  })
end

# Install nodejs from nodejs.org for versions 8 and above
if node[:nodejs][:version].to_i >= 8
  include_recipe "node::remote"
else
  include_recipe "node::portage"
end

cookbook_file '/etc/env.d/93node' do
  owner 'root'
  group 'root'
  source '93node'
  mode 0644
  only_if do
    File.directory?('/opt/nodejs/current/bin')
  end
end

execute "env-update" do
  command "env-update"
end

if node.engineyard.environment.component?('nodejs')
  include_recipe "node::ey_node_app_info"
end
