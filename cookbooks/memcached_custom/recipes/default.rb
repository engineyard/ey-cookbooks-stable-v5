require 'pp'
#
# Cookbook Name:: memcached
# Recipe:: default
#

include_recipe "memcached_custom::install"
include_recipe "memcached_custom::configure"
