# Report to Cloud dashboard
ey_cloud_report "processing php" do
  message "processing php - install"
end

# Unmask the PHP package (includes PHP-FPM)
enable_package node['php']['full_atom'] do
  version node['php']['version']
end
# Install PHP
package node['php']['full_atom'] do
  version node['php']['version']
  action :install
end

execute 'eslect php cli version' do
  command "eselect php set cli php#{node["php"]["minor_version"]}"
  not_if "php -v | grep PHP | grep #{node['php']['version']}"
end



# Install required extensions
# enable_package "dev-php/pecl-memcache" do
#   version "3.0.8-r1"
# end
# package "dev-php/pecl-memcache" do
#   version "3.0.8-r1"
#   action :install
# end

# enable_package "dev-php/pecl-apc" do
#   version "3.1.13"
# end

# package "dev-php/pecl-apc" do
#   version "3.1.13"
#   action :install
# end
# enable_package "dev-php/pecl-mongo" do
#   version "1.6.9"
# end
# package "dev-php/pecl-mongo" do
#   version "1.6.9"
#   action :install
# end
# enable_package "dev-php/pecl-redis" do
#   version "2.2.7-r1"
# end
# package "dev-php/pecl-redis" do
#   version "2.2.7-r1"
#   action :install
# end
