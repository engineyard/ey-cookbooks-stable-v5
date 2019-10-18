#
# Cookbook Name:: passenger5
# Recipe:: monitoring
#

if ['app_master', 'app', 'solo'].include?(node.dna['instance_role'])

  ey_cloud_report "passenger" do
    message "configuring passenger_monitor and passenger_killer"
  end

  node['dna']['applications'].each do |app_name, data|

    # And a script to warn if there are too few Rack processes:
    cookbook_file "/usr/local/bin/rack_counter" do
      mode 0755
      owner "root"
      group "root"
      source "rack_counter"
      backup false
      action :create
    end

    # When a Rack process grows to a certain size, passenger_monitor will try to kill it:
    max_megabytes = metadata_app_get_with_default(app_name, :worker_memory_size, 250)

    # We want to make sure there are at least this many Rack processes running on each app instance:
    min_rack_processes = (node[:dna][:environment][:framework_env] == 'production') ? 3 : 1

    # Here we are overriding EngineYard's default passenger_monitor cron entry so we can
    # increase the memory limit.  Otherwise, the web processes get killed off very quickly,
    # leading to performance problems.
    grace_time = metadata_app_get_with_default(app_name, :passenger_grace_time, 60)
    cron "passenger_monitor_#{app_name}" do
      minute '*'
      hour '*'
      day '*'
      weekday '*'
      month '*'
      command "/engineyard/bin/passenger_monitor #{app_name} -l #{max_megabytes} -w #{grace_time} >/dev/null 2>&1"
      action :create  # this actually replaces a cron entry if it already exists
    end

    # Or if there are too few Rack processes
    cron "rack_counter_#{app_name}" do
      minute '8,23,38,53'
      hour '*'
      day '*'
      weekday '*'
      month '*'
      command "/usr/local/bin/rack_counter -i '#{node[:dna][:environment][:framework_env]} #{node[:dna][:instance_role]}'  -w #{min_rack_processes} #{app_name} >/dev/null 2>&1"
      action :create  # this actually replaces a cron entry if it already exists
    end
  end

end
