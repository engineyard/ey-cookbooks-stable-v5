require 'pp'
#
# Cookbook Name:: memcached
# Recipe:: default
#

if node['memcached']['perform_install']
  include_recipe "memcached::install"
  include_recipe "memcached::configure"
end
