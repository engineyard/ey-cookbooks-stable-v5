#
# Cookbook Name:: env_vars
# Recipe:: cloud
#

if %w[solo app app_master util].include?(node['dna']['instance_role'])
  ssh_username = node['dna']['engineyard']['environment']['ssh_username']
  perform_restart = node['env_vars']['perform_restart']

  node['dna']['engineyard']['environment']['apps'].each do |app_data|
    app_name = app_data['name']

    template "/data/#{app_name}/shared/config/env.cloud" do
      source "env.cloud.erb"
      owner ssh_username
      group ssh_username
      mode 0744
      variables(:environment_variables => fetch_environment_variables(app_data))
      helpers(EnvVars::Helper)

      notifies :run, "execute[restart_#{app_name}]", :delayed
    end

    execute "restart_#{app_name}" do
      command "/engineyard/bin/app_#{app_name} restart"
      user ssh_username
      action :nothing
      only_if { perform_restart && ::File.exist?("/data/#{app_name}/current") && ::File.exist?("/engineyard/bin/app_#{app_name}")}
    end
  end
end
