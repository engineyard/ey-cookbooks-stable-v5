#
# Cookbook Name:: ey-dynamic
# Recipe:: packages
#
# Copyright 2008, Engine Yard, Inc.
#
# All rights reserved - Do Not Redistribute
#

ey_cloud_report "packages" do
  message "processing unix packages"
end

node.dna['packages_to_install'].each do |pkg|
  ey_cloud_report "each package" do
    message "processing package: #{pkg[:name]}"
  end
  package pkg[:name] do
    if pkg[:version] && !pkg[:version].empty?
      version pkg[:version]
    end
    action :install
  end
end
