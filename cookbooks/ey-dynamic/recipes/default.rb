#
# Cookbook Name:: ey-dynamic
# Recipe:: default
#
# Copyright 2008, Engine Yard, Inc.
#
# All rights reserved - Do Not Redistribute
#

include_recipe "ey-dynamic::user"
include_recipe "ey-dynamic::rubygems"
include_recipe "ey-dynamic::packages"

