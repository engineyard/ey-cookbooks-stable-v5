#
# Cookbook Name:: env_vars
# Recipe:: cloud
#

if %w[solo app app_master util].include?(node['dna']['instance_role'])
  ssh_username = node['dna']['engineyard']['environment']['ssh_username']
  perform_restart = node['env_vars']['perform_restart']

  node['dna']['engineyard']['environment']['apps'].each do |app_data|
    template "/data/#{app_data['name']}/shared/config/env.cloud" do
      source "env.cloud.erb"
      owner ssh_username
      group ssh_username
      mode 0744
      variables(:environment_variables => fetch_environment_variables(app_data))
      helpers(EnvVars::Helper)

      notifies :run, "execute[restart_#{app_data['name']}]", :delayed
    end

    execute "restart_#{app_data['name']}" do
      command "if [ -d /data/#{app_data['name']}/current ]; then /engineyard/bin/app_#{app_data['name']} restart; fi"
      user ssh_username
      action :nothing
    end
  end
end
