#
# Cookbook Name:: ec2
# Recipe:: default
#
# Copyright 2008, Engine Yard, Inc.
#
# All rights reserved - Do Not Redistribute

directory "/mnt/log" do
  owner 'root'
  group 'root'
  mode 0755
  not_if { File.exist?('/mnt/log') }
end

mount "/var/log" do
  device "/mnt/log"
  fstype "none"
  options "bind,rw"
  action :enable
end

data_mounted = Mixlib::ShellOut.new 'grep /data /etc/fstab'
data_mounted.run_command
# Mount a different volume if the instance is member of a cluster. This allows provisioned IOPS volumes to be mounted
if data_mounted.stdout == ""
  Chef::Log.info("EBS device being configured")

  ey_cloud_report "/data EBS" do
    message 'processing /data EBS'
  end

  while 1
    if node['data_volume'].found?
      directory "/data" do
        owner 'root'
        group 'root'
        mode 0755
      end

      bash "format-data-ebs" do
        code "mkfs.#{node['data_filesystem']} -j -F #{node['data_volume'].device}"
        not_if "e2label #{node['data_volume'].device}"
      end

      mount "/data" do
        fstype node['data_filesystem']
        device node['data_volume'].device
        pass 0
        action :mount
      end

      mount "/data" do
        action :enable
      end

      bash "grow-data-ebs" do
        code "resize2fs #{node['data_volume'].device}"
      end
      break
    end
    sleep 5
  end
end
