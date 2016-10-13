deviceid = File.read('/opt/.efsid').chomp
mount = node['efs']['mountpoint']


execute "umount -l -f #{mount}" do
  command "umount -l -f #{mount}"
end

mount "#{mount}" do
  device "#{deviceid}:/"
  fstype "nfs4"
  options "rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2"
  action :disable
end

file '/opt/.efsid' do
  action :delete
end
