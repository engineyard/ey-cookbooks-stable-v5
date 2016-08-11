#
# Cookbook Name:: emerge
# Recipe:: sync
#
# Copyright 2011, Engine Yard, Inc.
#
# All rights reserved - Do Not Redistribute

ey_cloud_report "report_emerge_sync" do
  message "processing portage update"
end

# Ensure that portage is up to date
execute "synchronize portage" do
  command "emerge --sync"
end

cookbook_file "/engineyard/bin/conditional-eix-sync" do
  owner "root"
  group "root"
  mode 0700
  source "conditional-eix-sync.sh"
  not_if { File.exist?('/engineyard/bin/conditional-eix-sync') }
end

# Trigger this to run in ten minutes (after the chef run completes)
# It takes a couple minutes and competes for CPU/IO.
# An updated eix search cache is not required during the chef run.
execute "update eix index" do
  command "/usr/bin/at -v -f /engineyard/bin/conditional-eix-sync now + 10 minutes"
end
