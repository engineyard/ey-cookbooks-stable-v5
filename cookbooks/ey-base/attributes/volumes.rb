
kernel_release = node['kernel']['release']
Chef::Log.info "Mounting devices for kernel #{kernel_release}"

default['data_volume'] = VariableTargetDevice.new("/data", ["/dev/xvdn","/dev/xvdz1"])
default['db_volume'] =   VariableTargetDevice.new("/db",   ["/dev/xvdm","/dev/xvdz2"])

if node['dna'][:engineyard][:environment][:components].find{|c| c['key'] == 'ext4'}[:value]
  default['data_filesystem'] = 'ext4'
  default['db_filesystem']   = 'ext4'
else
  default['data_filesystem'] = "ext3"
  default['db_filesystem'] = "ext3"
end
