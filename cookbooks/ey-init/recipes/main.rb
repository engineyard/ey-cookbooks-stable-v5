# Cookbook Name: ey-init
# Recipe: main
#
# Purpose: To initiate a full cookbook run to build or update an Engine Yard
#          instance
#
# Copyright 2016, Engine Yard, Inc.
#
# All rights reserved - Do Not Redistribute

require 'pp'
Chef::Log.info(ENV.pretty_inspect)

#include_recipe 'ey-base::chef_patches'
#include_recipe 'ey-base::resin_gems'
#include_recipe 'ey-core'
include_recipe "ec2" if ['solo', 'app', 'util', 'app_master','node'].include?(node.dna['instance_role'])

#include_recipe 'ey-custom::before-main'

#include_recipe 'ey-base::bootstrap' # common things that are installed in all the instances
#node.engineyard.instance.roles.each { |role| include_recipe "#{role}::prep" }
#node.engineyard.instance.roles.each { |role| include_recipe "#{role}::build" }
#include_recipe 'ey-base::post_bootstrap' # common things that we want to install setting up the instance

#include_recipe 'ey-custom::after-main'
