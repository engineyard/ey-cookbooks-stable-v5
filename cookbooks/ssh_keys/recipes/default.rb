#
# Cookbook Name:: ssh_keys
# Recipe:: default
#
# Copyright 2008, Engine Yard, Inc.
#
# All rights reserved - Do Not Redistribute
#

ey_cloud_report "ssh keys" do
  message "processing ssh keys"
end

directory "/home/#{node["owner_name"]}/.ssh" do
  owner node["owner_name"]
  group node["owner_name"]
  mode "0755"
end

[
  {
    :ssh_dir => "/home/#{node['owner_name']}/.ssh",
    :owner => node['owner_name'],
  }, {
    :ssh_dir => "/root/.ssh",
    :owner => 'root'
  }
].each do |ssh_info|
  ssh_dir = ssh_info[:ssh_dir]
  ssh_owner = ssh_info[:owner]

  ruby_block "copy-ssh-keys-for-#{ssh_owner}" do
    block do
      keys = [node['dna'][:user_ssh_key].to_a].flatten
      keys << node['dna'][:admin_ssh_key].to_s
      keys << %|from="#{node.cluster.join(",")}" #{node['dna'][:internal_ssh_public_key]}|.to_s

      File.open("#{ssh_dir}/authorized_keys.tmp", 'w') do |temp_key_file|
        keys.each do |key|
          temp_key_file.write(key.chomp)
          temp_key_file.write("\n")
        end

        if File.exist?("#{ssh_dir}/extra_authorized_keys")
          File.open("#{ssh_dir}/extra_authorized_keys", 'r') do |extra_keys|
            extra_keys.each_line do |extra_key|
              temp_key_file.write(extra_key)
            end
          end
        end

        passwd_entry = Etc.getpwnam(ssh_info[:owner])
        temp_key_file.chown(passwd_entry.uid, passwd_entry.gid)
        temp_key_file.chmod(0600)
      end

      File.rename("#{ssh_dir}/authorized_keys.tmp", "#{ssh_dir}/authorized_keys")
    end
  end

  template "#{ssh_dir}/internal" do
    owner ssh_owner
    group ssh_owner
    mode "0600"
    source "ssh.erb"
    variables({
        :key => node['dna'][:internal_ssh_private_key]
      })
  end
end
