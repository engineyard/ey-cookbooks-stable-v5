#
# Cookbook Name:: ey-bin
# Recipe:: default
#
# Copyright 2008, Engine Yard, Inc.
#
# All rights reserved - Do Not Redistribute
#

package 'sys-apps/ey-monit-scripts' do
  version node['ey_monit_scripts']['version']
  action :install
end
