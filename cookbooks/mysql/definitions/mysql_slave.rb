require 'tempfile'
require 'open-uri'
require 'right_aws'

mysql_slave_default_params = {
  :password => nil,
  :only_if => false,
}

define :mysql_slave, mysql_slave_default_params do
  master_host = params[:name]
  password = params[:password]

  execute "start-of-mysql-slave" do
    # Used to add only_ifs to these resources
    command "echo"
  end

  ruby_block "clean up half-done install" do
    block do
      system('/etc/init.d/mysql stop')
      system('umount /db')
      FileUtils.rmdir '/db'
    end

    # NB: there's already a guard such that we don't run if
    # replication is working. This code should only execute if /db is
    # mounted, but replication is busted, in which case we clean up
    # and start fresh.
    only_if { File.exists?("/db") }
  end

  directory "/db" do
    owner "mysql"
    group "mysql"
    mode 0755
    recursive true
  end

  ruby_block "wait-for-db-slave-volume" do
    block do
      until node['db_volume'].found? do
        sleep 5
      end
    end
  end

  mount "/db" do
    fstype node['db_filesystem']
    device node['db_volume'].device
    action [:mount, :enable]
    # override the not_if put on all these resources in the slave.rb recipe
    not_if "false"
  end

  ruby_block "wait-for-db-slave-mount" do
    block do
      until system("ls -l /db/mysql")
        sleep 3
        Array(resources(:mount => "/db")).each do |resource|
          resource.run_action(:mount)
        end
      end
    end
  end

  bash "grow-db-ebs" do
    code "resize2fs #{node['db_volume'].device}"
    only_if { node['db_volume'].found?}
  end

  handle_mysql_d

  volume_from_slave_snapshot = false
  ruby_block 'volume-from-slave-or-not' do
    block do
      volume_from_slave_snapshot = master_host == %x{[[ -f #{node['mysql']['datadir']}/master.info ]] && grep ec2 #{node['mysql']['datadir']}/master.info}.strip
    end
  end

  ruby_block 'read-master-status' do
    block do
      if not volume_from_slave_snapshot
        file_contents = File.read("/db/mysql/.snapshot_backup_master_status.txt")
        node.normal['master_log_file'] = file_contents.match(/File:(.*)\n/)[1].strip
        node.normal['master_log_pos'] = file_contents.match(/Position:(.*)\n/)[1].strip
        Chef::Log.info("using master_log_file: " + node['master_log_file'].inspect)
        Chef::Log.info("using master_log_pos: " + node['master_log_pos'].inspect)
      end
    end
  end

  file "#{node['mysql']['datadir']}/master.info" do
    action :delete
    only_if { File.exists?("#{node['mysql']['datadir']}/master.info") and not volume_from_slave_snapshot }
  end

  file "#{node['mysql']['datadir']}/relay-log.info" do
    action :delete
    only_if { File.exists?("#{node['mysql']['datadir']}/relay-log.info") and not volume_from_slave_snapshot }
  end

  execute "remove relay-log.*" do
    cwd node['mysql']['datadir']
    command "rm -f #{node['mysql']['datadir']}/relay-log.*"
    only_if { not Dir.glob("#{node['mysql']['datadir']}/relay-log.*").empty? and not volume_from_slave_snapshot }
  end

  execute "remove slave-relay*" do
    cwd node['mysql']['datadir']
    command "rm -f #{node['mysql']['datadir']}/slave-relay*"
    only_if { not Dir.glob("#{node['mysql']['datadir']}/slave-relay*").empty? and not volume_from_slave_snapshot }
  end
  
  # the master writes it's uuid to <datadir>/auto.cnf, the slave needs that removed so it will gen it's own
  execute "remove auto.cnf" do
    cwd node['mysql']['datadir']
    command "rm -f #{node['mysql']['datadir']}/auto.cnf"
    only_if { node['mysql']['short_version'] >= '5.6' }
  end

  include_recipe "mysql::startup"

  template "/tmp/clear_binlogs_from_slave.sh" do
    owner 'root'
    group 'root'
    mode "0755"
    source "clear_binlogs_from_slave.sh.erb"
    variables({ :datadir => node['mysql']['datadir']})
  end

  execute "clean-up-master's-bin-logs" do
    action :run
    command "/tmp/clear_binlogs_from_slave.sh"
    only_if %Q{mysql -e"show global variables like 'log_bin'"|grep 'OFF'}
  end

  ruby_block "setup-slave-database" do
    block do
      if not volume_from_slave_snapshot
        change_master_command =  "CHANGE MASTER TO"
        change_master_command << " MASTER_HOST='#{master_host}',"
        change_master_command << " MASTER_USER='replication',"
        change_master_command << " MASTER_PASSWORD='#{password}',"
        change_master_command << " MASTER_LOG_FILE='#{node['master_log_file']}',"
        change_master_command << " MASTER_LOG_POS=#{node[:master_log_pos]},"
        # Setup SSL
        change_master_command << " MASTER_SSL=1,"
        change_master_command << " MASTER_SSL_CA='#{node['mysql']['datadir']}/root.crt',"
        change_master_command << " MASTER_SSL_CERT='#{node['mysql']['datadir']}/server.crt',"
        change_master_command << " MASTER_SSL_KEY='#{node['mysql']['datadir']}/server.key'"

        Chef::Log.info "executing change master command"
        `mysql -e "#{change_master_command}"`

        Chef::Log.info "start slave"
        `mysql -e "start slave"`
      end
    end
  end

  execute "stop-of-mysql-slave" do
    # Used to add only ifs to these resources
    command "echo"
  end
end
