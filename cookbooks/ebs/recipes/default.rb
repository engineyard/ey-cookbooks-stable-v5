mount "/var/log" do
  device "/mnt/log"
  fstype "none"
  options "bind,rw"
  action :enable
end

if (`grep '/db ' /etc/fstab` == "")
  db_type = node.engineyard.environment['db_stack_name']
  case db_type
  when /mysql/
    db_owner = "mysql"
  when /postgres/
    db_owner = "postgres"
  when "no_db"
    #no-op
  else
    raise "I don't know who the owner should be for #{db_type}"
  end

  Chef::Log.info("#{db_type} EBS devices being formatted")

  ey_cloud_report "#{db_type} ebs" do
    message "processing /db EBS"
  end

  while 1
    if node['db_volume'].found?
      directory "/db" do
        owner db_owner
        group db_owner
        mode 0755
        recursive true
      end

      bash "format-db-ebs" do
        code "mkfs.#{node['db_filesystem']} -j -F #{node['db_volume'].device}"
        not_if "e2label #{node['db_volume'].device}"
      end

      mount "/db" do
        device node['db_volume'].device
        fstype node['db_filesystem']
        pass 0
        options "rw,noatime,data=ordered"
        action [:mount, :enable]
      end

      bash "grow-db-ebs" do
        code "resize2fs #{node['db_volume'].device}"
        timeout 7200
        only_if { node['db_volume'].found? }
      end
      break
    end
    sleep 5
  end
end
