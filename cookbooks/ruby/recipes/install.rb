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

#
# Require the right recipe to install the right flavor of ruby
#
# label        => recipe
#
# For instance:
#
# ruby_193     => ruby
# TODO (jf): remove this (see below)
# jruby_187    => jruby
# ree          => ree

# TODO (jf): remove jruby and ree
include_recipe "ruby::#{label.to_s[/([a-z]+).*/, 1]}"
include_recipe "ruby::rubygems"

# TODO (jf): find out why this is here - remove if possible
require "digest/md5"
# Remove the fakegem Rake wrapper
cookbook_file "/usr/bin/rake" do
  source "rake.txt"
  only_if { File.exist?("/usr/bin/rake") and Digest::MD5.hexdigest(File.read("/usr/bin/rake")) == "5d1f39b09f7e5f4962676e772ff1cf63" }
end
