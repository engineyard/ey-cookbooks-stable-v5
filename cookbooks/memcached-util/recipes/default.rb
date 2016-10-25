require 'pp'
#
# Cookbook Name:: memcached
# Recipe:: default
#

ey_cloud_report "memcached" do
  message "Installing memcached"
end

if node['memcached']['is_memcached_instance']
  node['dna']['applications'].each do |app_name,data|
    user = node['dna']['users'].first

    template "/data/#{app_name}/shared/config/memcached_custom.yml" do
      source "memcached.yml.erb"
      owner user[:username]
      group user[:username]
      mode 0744
      variables({
        :framework_env => node['dna']['environment']['framework_env'],
        :app_name => app_name,
        :server_names => node['dna']['members']
      })
    end

    template "/etc/conf.d/memcached" do
      source "memcached.erb"
      owner 'root'
      group 'root'
      mode 0644
      variables :memusage => 64,
        :port     => 11211
    end

    template '/etc/monit.d/memcached.monitrc' do
      source 'memcached.monitrc'
      owner 'root'
      group 'root'
      mode 0644
      notifies :run, 'execute[restart-monit]'
    end
  end
end
