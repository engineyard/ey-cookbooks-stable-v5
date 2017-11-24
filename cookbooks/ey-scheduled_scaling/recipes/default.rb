#
# Cookbook Name:: scheduled_scaling
# Recipe:: default
#

# Implementation notes

# Check if instance is the scaler
if !node['scheduled_scaling']['is_scheduler_instance']
  return
end

ey_cloud_report "Scheduled scaling" do
  message "processing scheduled scaling tasks"
end
Chef::Log.info "Processing scheduled scaling tasks"

# Install ey-core and optparse for the scripts to use
gem_package 'ey-core' do
  version "3.2.6"
  options "--no-user-install"
  action :install
end

# gem_package 'optparse' do
#   options "--no-user-install"
#   action :install
# end

# Pull CORE token from metadata and populate `/home/deploy/.ey-core`.

if ! core_api_token = node['dna']['engineyard']['environment']['components'].find {|component| component['key'] == 'environment_metadata'}['core_api_token']
  Chef::Log.fatal "There is no CoreAPI token specified on metadata, exiting..."
  exit(1)
end

username = node['dna']['engineyard']['environment']['ssh_username']
Chef::Log.info "Setting token for #{username}"
template "/home/#{username}/.ey-core" do
  owner username
  group username
  mode 0444
  source "dot_ey-core.erb"
  variables ({
    :core_api_token => core_api_token
  })
end

# Create logfile with correct permissions

file "/var/log/ey-scheduled_scaling.log" do
  owner username
  group username
  mode 0664
  action :create_if_missing
end

# Install scaling scripts.  Each script does a simple task (boot env, stop env, add instance, remove instance)

cookbook_file "/usr/local/bin/stop_environment.rb" do
  owner username
  group username
  mode 0755
  source "stop_environment.rb"
end

cookbook_file "/usr/local/bin/start_environment.rb" do
  owner username
  group username
  mode 0755
  source "start_environment.rb"
end

# Find all cron jobs specified in attributes/schedule.rb where current node name matches instance_name
scale_tasks = node['scheduled_scaling']['tasks'].find_all

scale_tasks.each do |scale_task|
  # Assemble specific scale operation. i.e.: generic script + specific parameters.
  if scale_task['type'] == 'stop_environment'
    scale_command = "/usr/local/bin/stop_environment.rb --account #{node['scheduled_scaling']['account']} --environment #{scale_task['environment_name']} --timeout #{scale_task['timeout']}"
  end
  if scale_task['type'] == 'start_environment'
    scale_command = "/usr/local/bin/start_environment.rb --account #{node['scheduled_scaling']['account']} --environment #{scale_task['environment_name']} --timeout #{scale_task['timeout']} --blueprint #{scale_task['blueprint_name']} --ip #{scale_task['ip_address']}"
  end
  
  cron scale_task[:name] do
    user     node['owner_name']
    action   :create
    minute   scale_task[:time].split[0]
    hour     scale_task[:time].split[1]
    day      scale_task[:time].split[2]
    month    scale_task[:time].split[3]
    weekday  scale_task[:time].split[4]
    command  scale_command
  end
end
