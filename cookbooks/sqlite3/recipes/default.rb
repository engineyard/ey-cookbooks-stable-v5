#
# Cookbook Name:: sqlite3
# Recipe:: default
#
# Copyright 2008, Engine Yard, Inc.
#
# All rights reserved - Do Not Redistribute
#

node.engineyard.apps.each do |app|
  next unless app.recipes.include?('sqlite3')

  gem_package "sqlite3-ruby" do
    action :install
  end

end
