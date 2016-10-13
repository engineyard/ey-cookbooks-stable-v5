this = attribute['dna']['engineyard']['this']
instance = attribute['dna']['engineyard']['environment']['instances'].find {|instance| instance['id'] == this}
deviceid = instance['components'].find {|component| component['key'] == 'efs'}.flatten[1]
mount = attribute['efs']['mountpoint']
shared = attribute['efs']['sharedfolder']


  directory "#{mount}" do
     owner 'root'
     group 'root'
     mode 0755
     not_if { File.exist?("#{mount}") }
   end

  mount "#{mount}" do
    device "#{deviceid}:/"
    fstype "nfs4"
    options "rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2"
    action :enable
  end


  directory "#{mount}#{shared}" do
     owner node['owner_name']
     group node['owner_name']
     mode 0755
     not_if { File.exist?("#{mount}#{shared}") }
   end
