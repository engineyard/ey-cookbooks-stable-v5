require 'pp'
#
# Cookbook Name:: memcached_custom
# Recipe:: configure
#
# This drops memcached.yml on all app and utility instances
#

ey_cloud_report "memcached" do
  message "Configuring memcached"
end

def get_app_instances
  node['dna']['engineyard']['environment']['instances'].
    select{|i| ['solo','app_master','app'].include?(i['role'])}.
    map{|i| i['private_hostname']}
end

def get_utils_by_name(util_name)
  node['dna']['utility_instances'].
    select{|i| i['name'] == util_name}.
    map{|i| i['hostname']}
end

# Get the list of memcached instances
memcached_instances = case node['memcached']['install_type']
when 'ALL_APP_INSTANCES'
  get_app_instances
else
  get_utils_by_name node['memcached']['utility_name']
end

# Drop the memcached.yml on all app and util instances
if ['app_master', 'app', 'util', 'solo'].include?(node['dna']['instance_role'])
  node['dna']['applications'].each do |app_name,data|
    user = node['dna']['users'].first

    template "/data/#{app_name}/shared/config/memcached.yml" do
      source "memcached.yml.erb"
      owner user[:username]
      group user[:username]
      mode 0744
      variables({
        :framework_env => node['dna']['environment']['framework_env'],
        :app_name => app_name,
        :server_names => memcached_instances
      })
    end

  end
end
