#
# Cookbook Name:: packages
# Recipe:: default
#

Chef::Log.info "PACKAGES: #{node['packages']}"
node['packages']['install'].each do |package|

  Chef::Log.info "PACKAGES: Installing #{package['name']}-#{package['version']}"

  enable_package package['name'] do
    version package['version']
    unmask true
    override hardmask true
  end

  package package['name'] do
    version package['version']
    action :install
    ignore_failure true
  end

end
