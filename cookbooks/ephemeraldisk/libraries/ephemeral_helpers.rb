require 'open3'

module EphemeralHelpers
  def _build_ephemeral_device(device, index)
    { device: device, index: index }
  end

  def _get_max_device_index(devices)
    devices.map { |dev| dev[:index] }.max || 0
  end

  def _list_xvd_ephemeral_devices(start_index: 1)
    %w(xvdd xvde)
      .each_with_index
      .select { |dev, i| File.exist?("/dev/#{dev}") }
      .map { |dev, i| _build_ephemeral_device("/dev/#{dev}", start_index+i) }
  end

  def _list_nvme_ephemeral_devices(start_index: 1)
    return [] if not Dir.exist?('/dev/disk/by-id')
    Dir.entries('/dev/disk/by-id')
      .select { |dev| dev.match(/^nvme-ephemeral-[a-zA-Z0-9]+$/) }
      .sort
      .each_with_index.map { |dev, i| _build_ephemeral_device("/dev/disk/by-id/#{dev}", start_index+i) }
  end

  def list_ephemeral_devices()
    xvd_devices = _list_xvd_ephemeral_devices(start_index: 1)
    max_device_id = _get_max_device_index(xvd_devices)
    nvme_devices = _list_nvme_ephemeral_devices(start_index: max_device_id+1)
    xvd_devices + nvme_devices
  end

  def get_mountpoint_for_ephemeral_device(device)
    "/tmp/eph#{device[:index]}"
  end

  def device_mounted?(device)
    _out, status = Open3.capture2("findmnt", "--source", device)
    status.success?
  end

  def device_size_in_bytes(device)
    out, status = Open3.capture2("blockdev", "--getsize64", device)
    if status.success?
      out.chomp.to_i
    else
      0
    end
  end

  def create_fs_and_mount(device, mountpoint)
    bash "format disk" do
      code "mkfs.ext4 -j #{device}"
    end
  
    execute "mkdir -p #{mountpoint}"

    mount mountpoint do
      fstype "ext4"
      device device
      action [:mount, :enable]
    end
  end
end

class Chef::Recipe
  include EphemeralHelpers
end
