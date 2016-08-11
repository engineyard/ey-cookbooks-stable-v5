#
# Cookbook Name:: chef
# Attribute File:: client.rb
#
# Copyright 2008, Engine Yard, Inc.
#
# All rights reserved - Do Not Redistribute
#

chef_server_config             "/etc/chef/server.rb"
chef_server_log_level          :info
chef_server_log_location       :stdout
chef_server_file_store_path    "/var/chef/file_store"
chef_server_file_cache_path    "/var/chef/cache"
chef_server_ssl_verify_mode    :verify_none
chef_server_registration_url   "http://chef:4000"
chef_server_openid_url         "http://chef:4001"
chef_server_template_url       "http://chef:4000"
chef_server_remotefile_url     "http://chef:4000"
chef_server_search_url         "http://chef:4000"
chef_server_cookbook_path      [ "/var/chef/site-cookbooks", "/var/chef/cookbooks" ]
chef_server_node_path          "/var/chef/nodes"
chef_server_openid_store_path  "/var/chef/openid/store"
chef_server_openid_cstore_path "/var/chef/openid/cstore"
chef_server_merb_log_path      "/var/log/chef-server.log"
chef_server_search_index_path  "/var/chef/search_index"
chef_server_openid_providers   [ "chef:4001" ]
chef_server_show_time_in_log   false
