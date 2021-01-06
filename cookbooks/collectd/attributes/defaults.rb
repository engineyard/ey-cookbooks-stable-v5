size = node[:dna][:environment][:instance_size] || ec2_instance_size
default['collectd'] = (default_collectd(size))
default['swap_warn_threshold'] = "0.50"
default['swap_crit_threshold'] = "0.70"
default['collectd']['nginx']['version'] = node.engineyard.metadata('nginx_ebuild_version','1.12.1')
default['collectd']['version'] = "5.4.1-r4"
# Enable monitoring of EC2/EBS credit balances only on T instances (T2, T3)
default['collectd']['enable_credit_balances_monitoring'] = (size =~ /^t[a-z0-9]+\./)
