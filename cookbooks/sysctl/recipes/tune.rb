#
# Cookbook Name:: sysctl
# Recipe:: tune
#
# There are some kernel parameters that default to values which are less than
# ideal for our typical use cases. This recipe is used to tune those defaults.
#

sysctl "Raise file-max" do
  variables 'fs.file-max' => node['sysctl']['file_max']
end

sysctl "Raise somaxconn" do
  variables 'net.core.somaxconn' => node['sysctl']['somaxconn']
end

sysctl "net.core.rmem_max" do
  variables 'net.core.rmem_max' => node['sysctl']['rmem_max']
end

sysctl "net.core.wmem_max" do
  variables 'net.core.wmem_max' => node['sysctl']['wmem_max']
end

sysctl "net.ipv4.tcp_mem" do
  variables 'net.ipv4.tcp_mem' => node['sysctl']['tcp_mem']
end

sysctl "net.ipv4.tcp_max_syn_backlog" do
  variables 'net.ipv4.tcp_max_syn_backlog' => node['sysctl']['max_syn_backlog']
  only_if "sysctl -a 2>/dev/null | grep 'tcp_syncookies = 1'" 
end

sysctl "net.ipv4.tcp_synack_retries" do
  variables 'net.ipv4.tcp_synack_retries' => node['sysctl']['synack_retries']
  only_if "sysctl -a 2>/dev/null | grep 'tcp_syncookies = 1'" 
end

sysctl "net.core.netdev_max_backlog" do
  variables 'net.core.netdev_max_backlog' => node['sysctl']['netdev_max_backlog']
end

sysctl "net.ipv4.tcp_tw_reuse" do
  variables 'net.ipv4.tcp_tw_reuse' => node['sysctl']['tw_reuse']
end

sysctl "net.ipv4.ip_local_port_range" do
  variables 'net.ipv4.ip_local_port_range' => node['sysctl']['local_port_range']
end

sysctl "net.ipv4.tcp_max_tw_buckets" do
  variables 'net.ipv4.tcp_max_tw_buckets' => node['sysctl']['max_tw_buckets']
end

sysctl "net.ipv4.tcp_max_orphans" do
  variables 'net.ipv4.tcp_max_orphans' => node['sysctl']['max_orphans']
end

if node['dna']['instance_role'][/db|solo/]
  include_recipe "sysctl::tune_large_db"
end
