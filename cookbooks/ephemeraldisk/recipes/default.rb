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
