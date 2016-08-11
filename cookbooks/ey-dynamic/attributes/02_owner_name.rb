#
# Cookbook Name:: ey-dynamic
# Attribute:: from_json
#
# Copyright 2008, Engine Yard, Inc.
#
# All rights reserved - Do Not Redistribute
#

# Set the owner_name to the first username
default['owner_name'] = (attribute[:dna][:users].first[:username])
default['owner_pass'] = (attribute[:dna][:users].first[:password])
