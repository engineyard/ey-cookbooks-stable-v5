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
    :home_dir => '/root/',
    :mysql_version => Gem::Version.new(node['mysql']['short_version']),
    :mysql_5_7 => Gem::Version.new('5.7'),
    :host => node.dna['instance_role'][/^(db|solo)/] ? 'localhost' : node.dna['db_host'],
  })
  source "user_my.cnf.erb"
end

template "/home/#{node["owner_name"]}/.my.cnf" do
  owner node["owner_name"]
  mode 0600
  variables ({
    :username => node["owner_name"],
    :password => node['owner_pass'],
    :home_dir => "/home/#{node['owner_name']}/",
    :mysql_version => Gem::Version.new(node['mysql']['short_version']),
    :mysql_5_7 => Gem::Version.new('5.7'),
    :host => node.dna['instance_role'][/^(db|solo)/] ? '127.0.0.1' : node.dna['db_host'],
  })
  source "user_my.cnf.erb"
end
