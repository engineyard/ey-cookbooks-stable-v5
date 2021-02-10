#
# Cookbook Name:: thinking_sphinx_3
# Recipe:: setup
#

if node['sphinx']['is_thinking_sphinx_instance'] 
  # report to dashboard
  ey_cloud_report "sphinx" do
    message "Setting up sphinx"
  end
  
  node['sphinx']['applications'].each do |app_name|
    # monit
    execute "restart-sphinx-#{app_name}" do
      command "monit reload && sleep 2s && monit restart sphinx_#{app_name}"
      action :nothing
    end
    
    # setup monit for each app defined (see attributes)
    template "/etc/monit.d/sphinx_#{app_name}.monitrc" do
      source "sphinx.monitrc.erb"
      owner node['owner_name']
      group node['owner_name']
      mode "0644"
      backup 0
      variables({
        :environment => node['dna']['environment']['framework_env'],
        :user => node[:owner_name],
        :pid_file => "/data/#{app_name}/shared/log/#{node['dna']['environment']['framework_env']}.sphinx.pid",
        :app_name => app_name
      })
      notifies :run, resources(:execute => "restart-sphinx-#{app_name}")
    end

    # indexer cron job
    if node['sphinx']['frequency'].to_i > 0
      cron "indexer-#{app_name}" do
        command "/usr/bin/indexer -c /data/#{app_name}/current/config/#{node['dna']['environment']['framework_env']}.sphinx.conf --all --rotate"
        minute "*/#{node['sphinx']['frequency']}"
        user node['owner_name']
      end
    end
  end
end