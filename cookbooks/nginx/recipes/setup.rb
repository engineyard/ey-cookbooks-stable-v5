# configure and setup
include_recipe 'nginx::configure'
include_recipe 'nginx::cleanup'

nginx_version = node.engineyard.metadata("nginx_ebuild_version", node['nginx'][:version])

# link config
link "/etc/nginx" do
  to "/data/nginx"
end

# install

enable_package 'www-servers/nginx' do
  version nginx_version
  unmaskfile 'nginx'
end

package "www-servers/nginx" do
  version nginx_version
end

cookbook_file "/etc/init.d/nginx" do
  owner "root"
  group "root"
  mode 0755
  source "nginx"
end

# Nginx upgrade handled in nginx::default called by dna recipes[] list - CC-656

# This should become a service resource, once we have it for gentoo
# runlevel 'nginx' do
#   action :add
# end
