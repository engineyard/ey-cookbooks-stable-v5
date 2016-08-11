#
# Cookbook Name:: sudo
# Recipe:: default
#
# Copyright 2008, Engine Yard, Inc.
#
# All rights reserved - Do Not Redistribute
#

template "/etc/sudoers" do
  owner "root"
  group "root"
  source "sudoers.erb"
  mode "0440"
end
