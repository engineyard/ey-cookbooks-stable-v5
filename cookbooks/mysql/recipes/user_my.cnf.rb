#
# Cookbook Name:: mysql
# Recipe:: user_my.cnf.rb
#
# Copyright 2008, Engine Yard, Inc.
#
# All rights reserved - Do Not Redistribute

template "/root/.my.cnf" do
  owner 'root'
  mode 0600
  variables ({
    :username => 'root',
    :password => node['owner_pass'],
  })
  source "user_my.cnf.erb"
end

template "/home/#{node["owner_name"]}/.my.cnf" do
  owner node["owner_name"]
  mode 0600
  variables ({
    :username => node["owner_name"],
    :password => node['owner_pass'],
  })
  source "user_my.cnf.erb"
end