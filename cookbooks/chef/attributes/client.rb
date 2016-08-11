#
# Cookbook Name:: chef
# Attribute File:: client.rb
#
# Copyright 2008, Engine Yard, Inc.
#
# All rights reserved - Do Not Redistribute
#

chef_client_config           "/etc/chef/client.rb"
chef_client_log_level        :info
chef_client_log_location     :stdout
chef_client_file_store_path  "/var/chef/file_store"
chef_client_file_cache_path  "/var/chef/cache"
chef_client_ssl_verify_mode  :verify_none
chef_client_registration_url "http://chef:4000"
chef_client_openid_url       "http://chef:4001"
chef_client_template_url     "http://chef:4000"
chef_client_remotefile_url   "http://chef:4000"
chef_client_search_url       "http://chef:4000"


