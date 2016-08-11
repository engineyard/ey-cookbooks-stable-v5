#
# Cookbook Name:: framework_env
# Recipe:: default
#
# Copyright 2009, Engine Yard, Inc.
#
# All rights reserved - Do Not Redistribute
#

ruby_block "set-internal-framework-env" do
  block do
    ENV["RAILS_ENV"] = node.dna['environment']['framework_env'].to_s
    ENV["MERB_ENV"] = node.dna['environment']['framework_env'].to_s
    ENV["RACK_ENV"] = node.dna['environment']['framework_env'].to_s
  end
end
