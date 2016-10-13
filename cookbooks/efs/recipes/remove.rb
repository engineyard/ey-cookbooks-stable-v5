deviceid = File.read(/opt/.efsid)
mount = node['efs']['mountpoint']

mount "#{mount}" do
  device "#{deviceid}:/"
  fstype "nfs4"
  options "rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2"
  action [:unmount, :disable]
  only_if { File.exist?("/opt/.efsid")}
end

file '/opt/.efsid' do
  action :delete
end
