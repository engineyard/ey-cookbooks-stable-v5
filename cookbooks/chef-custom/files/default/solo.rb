require 'open-uri'
cookbook_path     "/etc/chef-custom/recipes/cookbooks"
log_level         :info
file_store_path  "/etc/chef-custom/recipes/"
file_cache_path  "/etc/chef-custom/recipes/"
node_name open("http://169.254.169.254/latest/meta-data/instance-id").gets
Chef::Log::Formatter.show_time = false