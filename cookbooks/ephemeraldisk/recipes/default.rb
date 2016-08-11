[['/dev/xvdd', '/tmp/eph1'],['/dev/xvde', '/tmp/eph2']].each do |device, mount|
  blockdev = Mixlib::ShellOut.new "blockdev --getsize64 #{device}"
  blockdev.run_command
  if File.foreach("/proc/mounts").any?{ |line| line[device] } 
    Chef::Log.info("#{device} already mounted")
  elsif File.exist?(device) and blockdev.stdout.chomp.to_i > 30000000000
    bash "format disk" do
      code "mkfs.ext4 -j #{device}"
    end
  
    execute "mkdir #{mount}"
  
    mount mount do
      fstype "ext4"
      device device
      action [:mount, :enable]
    end
  else
    Chef::Log.info("#{device} does not exist")
  end
end
