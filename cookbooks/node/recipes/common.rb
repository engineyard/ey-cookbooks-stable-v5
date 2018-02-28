get_package_name = {
  '4.4.5' => 'net-libs/nodejs',
}
get_package_name.default = 'net-libs/nodejs'

unmask_package "dev-libs/libuv" do
  version node['nodejs']['libuv']['version']
  unmaskfile "libuv"
end

enable_package 'dev-libs/libuv' do
  version node['nodejs']['libuv']['version']
end

directory "/mnt/node/tmp" do
  action :delete
  recursive true
end

directory "/opt/node" do
  action :delete
  recursive true
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
available_nodejs_versions = node['nodejs']['available_versions'].sort {|x,y| Engineyard::Version.new(x) <=> Engineyard::Version.new(y)}

nodejs_version_to_install_and_eselect = node['nodejs']['version']

 # Enable all versions of node we provide
 available_nodejs_versions.each do |nodejs_version|
   enable_package get_package_name[nodejs_version] do
     version nodejs_version
   end
 end

# 0.12.x needs extra packages enabled
if (available_nodejs_versions & %w(0.12.6 0.12.7 0.12.10)).length > 0
  enable_package 'net-libs/http-parser' do
    version '2.6.2'
  end
  enable_package 'dev-libs/libuv' do
    version '1.8.0'
  end
end

# # Enable and install a system node
 unmask_package get_package_name[nodejs_version_to_install_and_eselect] do
   version nodejs_version_to_install_and_eselect
   unmaskfile "nodejs"
 end

# # Update the attributes
 node.normal['nodejs']['version'] = nodejs_version_to_install_and_eselect
 node.normal['nodejs']['available_versions'] = available_nodejs_versions


 package get_package_name[nodejs_version_to_install_and_eselect] do
   version nodejs_version_to_install_and_eselect
 end

nodejs_version_to_eselect_trimmed = nodejs_version_to_install_and_eselect.split("-r").first
eselect nodejs_version_to_eselect_trimmed do
  slot 'nodejs'
end

current_node_dir = "/opt/nodejs/#{node['nodejs']['version'].sub(/-r.*/, '')}"
link '/opt/nodejs/current' do
  to current_node_dir
  only_if do
    File.directory?(current_node_dir)
  end
end

extended_node_dir = "/opt/nodejs/#{node['nodejs']['version']}"
link extended_node_dir do
  to current_node_dir
  only_if do
    extended_node_dir != current_node_dir
  end
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

# Leave a .json with the node versions we provide
["/opt" "/opt/nodejs"].each do |dir|
  directory dir do
    owner 'root'
    group 'root'
    mode 0755
    recursive true
  end
end

directory "/opt/nodejs" do
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

# Install yarn. YT-CC-1132.
package 'sys-apps/yarn' do
  version '0.21.3-r1'
end

if node.engineyard.environment.component?('nodejs')
  include_recipe "node::ey_node_app_info"
end
