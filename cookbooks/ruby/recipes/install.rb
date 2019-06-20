component = node.engineyard.environment.ruby
label = component[:full_version]

ey_cloud_report "ruby install" do
  message "processing #{label}"
end

# Install the eselect ruby bits so we can eselect the ruby we want
#package "app-admin/eselect-ruby" do
#  action :install
#  version '20141227'
#end

# Remove a mirror hosts file entry that may be part of the AMI
execute 'remove-mirror-from-etc-hosts' do
  command "sed -i -e '/^.*gems\.rubyforge\.org.*$/d' /etc/hosts"
end

# Use our gemrc
cookbook_file "/etc/gemrc" do
  source "gemrc"
end

# Add gemrc for the root user
cookbook_file "/root/.gemrc" do
  source "gemrc"
end

include_recipe "ruby::ruby"
include_recipe "ruby::rubygems"
