#
# Cookbook Name:: passenger5
# Recipe:: default
#

include_recipe "passenger5::install"
include_recipe "passenger5::monitoring"
include_recipe "passenger5::cleanup_passenger"
