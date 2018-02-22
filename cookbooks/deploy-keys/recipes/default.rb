#
# Cookbook Name:: deploy-keys
# Recipe:: default
#
# Copyright 2008, Engine Yard, Inc.
#
# All rights reserved - Do Not Redistribute
#


ey_cloud_report "deploy keys" do
  message 'processing deploy keys'
end

directory "/home/#{node["owner_name"]}/.ssh" do
  owner node["owner_name"]
  group node["owner_name"]
  mode 0700
  action :create
end

node['dna']['applications'].each do |app, data|

  if data[:deploy_key]

    update_file "add-#{app}-key-for-root" do
      action :rewrite
      path "/root/.ssh/#{app}-deploy-key"
      mode 0600
      body data[:deploy_key]
    end

    update_file "add-#{app}-key-for-#{node["owner_name"]}" do
      action :rewrite
      path "/home/#{node["owner_name"]}/.ssh/#{app}-deploy-key"
      mode 0600
      body data[:deploy_key]
      owner node["owner_name"]
      group node["owner_name"]
    end
  end
end
