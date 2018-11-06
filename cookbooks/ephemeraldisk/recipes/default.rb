# [['/dev/xvdd', '/tmp/eph1'],['/dev/xvde', '/tmp/eph2']].each do |device, mount|
#   blockdev = Mixlib::ShellOut.new "blockdev --getsize64 #{device}"
#   blockdev.run_command
#   # TODO: use findmnt --source #{device} here
#   if File.foreach("/proc/mounts").any?{ |line| line[device] } 
#     Chef::Log.info("#{device} already mounted")
#   elsif File.exist?(device) and blockdev.stdout.chomp.to_i > 30000000000
#     bash "format disk" do
#       code "mkfs.ext4 -j #{device}"
#     end
  
#     execute "mkdir #{mount}"
  
#     mount mount do
#       fstype "ext4"
#       device device
#       action [:mount, :enable]
#     end
#   else
#     Chef::Log.info("#{device} does not exist")
#   end
# end

list_ephemeral_devices().each do |device_info|
  device = device_info[:device]
  if device_mounted?(device)
    Chef::Log.info("#{device} already mounted")
  elsif File.exist?(device) and device_size_in_bytes(device) > 30000000000
    mountpoint = get_mountpoint_for_ephemeral_device(device_info)
    create_fs_and_mount(device, mountpoint)
  else
    Chef::Log.info("#{device} does not exist")
  end
end
