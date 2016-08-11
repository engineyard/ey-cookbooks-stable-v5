# Cookbook Name:: ey-base
# Recipe:: default
#
# Copyright 2008, Engine Yard, Inc.
#
# All rights reserved - Do Not Redistribute

require 'pp'
Chef::Log.info(ENV.pretty_inspect)
include_recipe 'ey-base::chef_patches'
include_recipe 'ey-base::resin_gems'

include_recipe 'ey-base::bootstrap' # common things that are installed in all the instances
node.engineyard.instance.roles.each { |role| include_recipe "#{role}::prep" }
node.engineyard.instance.roles.each { |role| include_recipe "#{role}::build" }
include_recipe 'ey-base::post_bootstrap' # common things that we want to install setting up the instance

# Insert any post bootstrap work into the post_bootstrap recipe; i.e. NOT HERE.
