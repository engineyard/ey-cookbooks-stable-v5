deviceid = File.read('/opt/.efsid').chomp
mount = node['efs']['mountpoint']

mount "#{mount}" do
  device "#{deviceid}:/"
  fstype "nfs4"
  options "rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2"
  action [:umount, :disable]
end

file '/opt/.efsid' do
  action :delete
end
