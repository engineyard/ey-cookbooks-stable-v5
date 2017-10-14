#
# Cookbook Name:: env_vars
# Recipe:: cloud
#

if %w[solo app app_master util].include?(node['dna']['instance_role'])
  ssh_username = node['dna']['engineyard']['environment']['ssh_username']

  node['dna']['engineyard']['environment']['apps'].each do |app_data|
    app_name = app_data['name']

    template "/data/#{app_name}/shared/config/env.cloud" do
      source "env.cloud.erb"
      owner ssh_username
      group ssh_username
      mode 0744
      variables(:environment_variables => fetch_environment_variables(app_data))
      helpers(EnvVars::Helper)
    end
  end
end
