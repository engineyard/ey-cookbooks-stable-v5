#
# Cookbook Name:: ey-dynamic
# Recipe:: rubygems
#
# Copyright 2008, Engine Yard, Inc.
#
# All rights reserved - Do Not Redistribute
#

## EY role acount should come first in the node.dna[:users] array

ey_cloud_report "custom gems" do
  message "processing custom gems"
end

ruby_block "gems to install" do
  block do
    node.dna['gems_to_install'].each do |pkg|
      command = "gem install #{pkg[:name]} --no-ri --no-rdoc"
      command << " -v #{pkg[:version]}" if pkg[:version]

      Array(pkg[:source]).each do |source|
        command << " --source #{source}"
      end

      system(command)
    end
  end
end


bash "remove engineyard gem source" do
  code <<-EOH
    gem sources -r http://gems.engineyard.com
  EOH
  only_if "gem sources | grep http://gems.engineyard.com"
end
