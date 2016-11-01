require 'pp'
#
# Cookbook Name:: memcached
# Recipe:: default
#

include_recipe "memcached-util::install"
include_recipe "memcached-util::configure"
