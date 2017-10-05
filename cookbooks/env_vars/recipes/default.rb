#
# Cookbook Name:: env_vars
# Recipe:: default
#

if ['solo', 'app', 'app_master', 'util'].include?(node['dna']['instance_role'])

  ssh_username = node['dna']['engineyard']['environment']['ssh_username']
  perform_restart = node['env_vars']['perform_restart']

  node['dna']['applications'].each do |app_name, data|
    cookbook_file "/data/#{app_name}/shared/config/env.custom" do
      cookbook 'custom-env_vars'
      source "env.custom"
      owner ssh_username
      group ssh_username
      mode 0744
    end

    execute "/engineyard/bin/app_#{app_name} restart" do
      action :run
      user ssh_username
      only_if { perform_restart && ::File.exist?("/data/#{app_name}/current") && ::File.exist?("/engineyard/bin/app_#{app_name}")}
    end
  end

end
