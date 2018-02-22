#
# Cookbook Name:: ey-dynamic
# Recipe:: default
#
# Copyright 2008, Engine Yard, Inc.
#
# All rights reserved - Do Not Redistribute
#

ey_cloud_report "users" do
  message "processing users"
end

## EY role account should come first in the node['dna'][:users] array
node['dna']['users'].each do |user_obj|
  execute "create-group" do
    command "groupadd -g #{user_obj[:gid]} #{user_obj[:username]}"
    not_if "getent group #{user_obj[:gid]}"
  end

  user "create-user" do
    username user_obj[:username]
    uid user_obj[:uid]
    gid user_obj[:gid].to_i if user_obj[:gid]
    shell "/bin/bash"
    password user_obj[:password]
    comment user_obj[:comment]
    manage_home false

    not_if "getent passwd #{user_obj[:uid]}"
  end

  execute "update-username" do
    command "usermod -l #{user_obj[:username]} --home /home/#{user_obj[:username]} --move-home `getent passwd #{user_obj[:uid]} | cut -d \":\" -f 1` && groupmod --new-name #{user_obj[:username]} `getent group #{user_obj[:uid]} | cut -d \":\" -f 1`"
    only_if do user_obj[:username] != `getent passwd #{user_obj[:uid]} | cut -d \":\" -f 1`  end
  end

  directory "/data/homedirs/#{user_obj[:username]}" do
    owner user_obj[:username]
    group user_obj[:username]
    mode 0755
    recursive true
  end

  link "/home/#{user_obj[:username]}" do
    to "/data/homedirs/#{user_obj[:username]}"
    not_if { File.exist? "/home/#{user_obj[:username]}" }
  end

  execute "add base dotfiles" do
    command "rsync -aq /etc/skel/ /home/#{user_obj[:username]}"
    not_if { File.exists? "/home/#{user_obj[:username]}/.bashrc" }
  end

  execute "chown homedir to user" do
    command "chown -R #{user_obj[:username]}:#{user_obj[:username]} /data/homedirs/#{user_obj[:username]}"
  end
end
