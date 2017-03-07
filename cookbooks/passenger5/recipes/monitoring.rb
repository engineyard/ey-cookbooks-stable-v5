#
# Cookbook Name:: passenger5
# Recipe:: monitoring
#

if ['app_master', 'app', 'solo'].include?(node.dna['instance_role'])

  ey_cloud_report "passenger" do
    message "configuring passenger_monitor and passenger_killer"
  end

  node['dna']['applications'].each do |app_name, data|

    # A script to kill VERY large Rack processes with prejudice:
    cookbook_file "/usr/local/bin/passenger_killer" do
      mode 0755
      owner "root"
      group "root"
      source "passenger_killer"
      backup false
      action :create
    end

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
    max_megabytes = 800
    # When a Rack process grows to a huge size, passenger_killer will kill it with prejudice
    huge_megabytes = 1200
    case node['ec2']['instance_type']
    when "m1.small"
      max_megabytes = 400
      huge_megabytes = 600
    when "m1.medium"
      max_megabytes = 500
      huge_megabytes = 750
    when "m1.large"
      max_megabytes = 800
      huge_megabytes = 1200
    when "m1.xlarge"
      max_megabytes = 1000
      huge_megabytes = 1500
    when "c1.medium"
      max_megabytes = 400
      huge_megabytes = 600
    when "c1.xlarge"
      max_megabytes = 800
      huge_megabytes = 1200
    when "m2.xlarge"
      max_megabytes = 800
      huge_megabytes = 1200
    when "m2.2xlarge"
      max_megabytes = 1000
      huge_megabytes = 1500
    when "m2.4xlarge"
      max_megabytes = 1500
      huge_megabytes = 2000
    end
    # We want to make sure there are at least this many Rack processes running on each app instance:
    min_rack_processes = (node[:dna][:environment][:framework_env] == 'production') ? 3 : 1

    # Here we are overriding EngineYard's default passenger_monitor cron entry so we can
    # increase the memory limit.  Otherwise, the web processes get killed off very quickly,
    # leading to performance problems.
    cron "passenger_monitor_#{app_name}" do
      minute '*'
      hour '*'
      day '*'
      weekday '*'
      month '*'
      command "/engineyard/bin/passenger_monitor #{app_name} -l #{max_megabytes} >/dev/null 2>&1"
      action :create  # this actually replaces a cron entry if it already exists
    end

    # We also notify wookie if any processes need to get killed.
    cron "passenger_killer_#{app_name}" do
      minute '0,15,30,45'
      hour '*'
      day '*'
      weekday '*'
      month '*'
      command "/usr/local/bin/passenger_killer -l #{huge_megabytes} #{app_name} >/dev/null 2>&1"
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
