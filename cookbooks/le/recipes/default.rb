#
# Cookbook Name:: le
# Recipe:: default
#
include_recipe 'le::install'
include_recipe 'le::configure'
include_recipe 'le::start'
