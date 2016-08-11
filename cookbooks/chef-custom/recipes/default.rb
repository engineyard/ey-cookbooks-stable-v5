#
# Cookbook Name:: chef-custom
# Recipe:: default
#
# Copyright 2009, Engine Yard, Inc.
#
# All rights reserved - Do Not Redistribute
#


directory "/etc/chef-custom" do
  owner node["owner_name"]
  group node["owner_name"]
  mode 0755
end

cookbook_file "/etc/chef-custom/solo.rb" do
  owner node["owner_name"]
  group node["owner_name"]
  mode 0755
  source "solo.rb"
end
