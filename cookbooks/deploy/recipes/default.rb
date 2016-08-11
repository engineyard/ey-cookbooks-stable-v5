#
# Cookbook Name:: deploy
# Recipe:: default
#
# Copyright 2009, Engine Yard, Inc.
#
# All rights reserved - Do Not Redistribute
#

ey_cloud_report "creating deploy user" do
  message %{creating deploy user "#{node["owner_name"]}"}
end

user node["owner_name"]

applications_to_deploy.each do |app, data|

  msg = if (data[:run_migrations] && ['solo', 'app_master'].include?(node.dna['instance_role']))
    "deploying & migrating #{app}"
  else
    "deploying #{app}"
  end

  if data[:deploy_action] == 'rollback'
    msg = "rolling back #{app}"
  end

  ey_cloud_report "deploying: #{app}" do
    message msg
  end

  cmd = ""

  recipes = node.dna['applications'].collect{|name,data|  data[:recipes]}.flatten
  unless (recipes & ['passenger', 'nginx-passenger']).empty?
    cmd = "/engineyard/bin/app_#{app} deploy"
  end

  if node.dna['instance_role'] == 'util'
    cmd = ""
  end

  template "/tmp/deploy-#{app}-ssh-config" do
    mode 0600
    owner node["owner_name"]
    source "ssh-config.erb"
    variables({
      :app_name => app
    })
  end

  template "/tmp/deploy-#{app}-git-ssh" do
    mode 0700
    owner node["owner_name"]
    source "git-ssh.erb"
    variables({
        :ssh_config_file => ["/tmp/deploy-#{app}-ssh-config"]
      })
  end

  template "/data/#{app}/shared/config/git-ssh-config" do
    mode 0600
    owner node["owner_name"]
    source "ssh-config.erb"
    variables({
      :app_name => app
    })
  end

  template "/data/#{app}/shared/bin/git-ssh" do
    mode 0755
    owner node["owner_name"]
    source "git-ssh.erb"
    variables({
        :ssh_config_file => ["/data/#{app}/shared/config/git-ssh-config"]
      })
  end

  template "/data/#{app}/shared/config/git-env" do
    mode 0644
    owner node["owner_name"]
    source "git-env.erb"
    variables({
      :git_ssh_file => ["/data/#{app}/shared/bin/git-ssh"]
    })
  end

  template "/data/#{app}/shared/bin/git" do
    mode 0755
    owner node["owner_name"]
    source "git.erb"
    variables({
        :git_ssh_file => ["/data/#{app}/shared/bin/git-ssh"]
      })
  end

  execute "ensure-permissions-for-#{app}" do
    command "chown -R #{node["owner_name"]}:#{node["owner_name"]} /data/#{app}"
  end
end

execute "after-deploy-resources" do
  command "date" #noop

  unless node.dna['_after_deploy_resources'].nil?
    node.dna['_after_deploy_resources'].each do |resource, action|
      notifies action, resource
    end
  end

  not_if do
    node.dna['_after_deploy_resources'].nil? || node.dna['_after_deploy_resources'].empty?
  end
end
