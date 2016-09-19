get_package_name = {
  '4.4.5' => 'net-libs/nodejs',
}
get_package_name.default = 'net-libs/nodejs'

unmask_package "dev-libs/libuv" do
  version node['nodejs']['libuv']['version']
  unmaskfile "libuv"
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

#bash 'add v8' do
#  code 'echo "=dev-lang/v8-3.11.10.12 ~amd64" >>/etc/portage/package.keywords/local'
#end

#available_nodejs_versions = /Available versions:\s+(.*)$/.
#  match(`eix -xn net-libs/nodejs`)[1].
#  split.
#  collect {|v| v =~ /(\(?[\d\.]+\)?)/; $1}.
#  compact.
#  sort {|x,y| Engineyard::Version.new(x) <=> Engineyard::Version.new(y)}.
#  uniq

available_nodejs_versions = node['nodejs']['available_versions'].sort {|x,y| Engineyard::Version.new(x) <=> Engineyard::Version.new(y)}

nodejs_version_specs_for_apps = []
# If there's more than one app, then the assumption will be that the system node.js should be
# the highest version specified by the apps.
node.engineyard.apps.each do |app|
  package_json_path = File.join('/data/', app.name, 'current', 'package.json')
  next unless FileTest.exist? package_json_path
  package_data = JSON.parse(File.read(package_json_path))
  nodejs_version_specs_for_apps << ( package_data['engines'] && package_data['engines']['node'] )
end

nodejs_version_specs_for_apps << node['nodejs']['version'] if nodejs_version_specs_for_apps.empty?

nodejs_version_specs_for_apps = nodejs_version_specs_for_apps.collect do |spec|
  case spec
  when /\*/
    '> 0.0'
  when /([\d\.]+)\.x/
    "~>#{$1}.0"
  else
    spec
  end
end.select do |spec|
  # Trim out any specifications that aren't parseable
  begin
    Engineyard::Requirement.new(spec)
  rescue
    nil
  end
end.collect do |spec|
  # If the version spec doesn't match any available version, then we'll transform it to something
  # more likely to have a nominally acceptable match, instead of just ignoring it. This is more
  # likely to result in the right thing being done than just pretending that the unfulfullable
  # specification doesn't exist.
  requirement = Engineyard::Requirement.new( spec )
  if available_nodejs_versions.any? { |version| requirement === Engineyard::Version.new( version ) }
    spec
  else
    spec =~ /([\d\.]+)/
    flat_spec = $1
    available_nodejs_versions.flatten.select do |version|
      Engineyard::Version.new(version) > Engineyard::Version.new(flat_spec) ? version : nil
    end.first
  end
end

all_nodejs_version_specs_for_apps = Engineyard::Requirement.new( nodejs_version_specs_for_apps )

globally_acceptable_nodejs_versions = available_nodejs_versions.select do |version|
  all_nodejs_version_specs_for_apps === Engineyard::Version.new( version )
end.sort {|x,y| Engineyard::Version.new(x) <=> Engineyard::Version.new(y)}

if globally_acceptable_nodejs_versions.any?
  nodejs_version_to_install_and_eselect = globally_acceptable_nodejs_versions.last
else
  greatest_good_nodejs_versions = Hash.new {|h,k| h[k] = 0}
  nodejs_version_specs_for_apps.each do |version_spec|
    requirement = Engineyard::Requirement.new( version_spec )
    available_nodejs_versions.select do |version|
      greatest_good_nodejs_versions[version] += 1 if requirement === Engineyard::Version.new( version )
    end
  end
  most_popular_count = greatest_good_nodejs_versions.
    values.
    sort.
    last
  nodejs_version_to_install_and_eselect = greatest_good_nodejs_versions.
    keys.
    select {|k| greatest_good_nodejs_versions[k] == most_popular_count}.
    sort {|x,y| Engineyard::Version.new(x) <=> Engineyard::Version.new(y)}.
    last
end

# If the code can't figure out a good specific version to use based on the contents of the package.json
# file or files, then we'll punt and just use the attributes/node.rb default.
nodejs_version_to_install_and_eselect = nodejs_version_to_install_and_eselect || node['nodejs']['version']

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

# Enable and install a system node
unmask_package get_package_name[nodejs_version_to_install_and_eselect] do
  #version "#{node.dna['nodejs']['version']}"
  version nodejs_version_to_install_and_eselect
  unmaskfile "nodejs"
end

# Update the attributes
node.normal['nodejs']['version'] = nodejs_version_to_install_and_eselect
node.normal['nodejs']['available_versions'] = available_nodejs_versions

#Commenting out due to portage issues. Believe this should be able to be Removed going forward.
# package "app-admin/eselect-nodejs" do
#   version "20120820"
# end

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


#TODO: REMOVE BEFORE NEW DISTRO RELEASE
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

if node.engineyard.environment.component?('nodejs')
  include_recipe "node::ey_node_app_info"
end
