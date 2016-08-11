require 'tempfile'
require 'open-uri'
require 'right_aws'

postgresql_slave_default_params = {
  :password => nil,
  :only_if => false,
}

define :postgresql_slave, postgresql_slave_default_params do
  master_host = params[:name]
  password = params[:password]
  postgres_version = node['postgresql']['short_version']

  ruby_block "clean up half-done install" do
    block do
      system('/etc/init.d/postgresql-#{postgres_version} stop')
      system('umount /db')
      FileUtils.rmdir '/db'
    end

    # NB: there's already a guard such that we don't run if
    # replication is working. This code should only execute if /db is
    # mounted, but replication is busted, in which case we clean up
    # and start fresh.
    only_if { File.exists?("/db") }
  end

  execute "stop postgresql" do
    command "/etc/init.d/postgresql-#{postgres_version} stop"
  end

  directory "/db" do
    owner "postgres"
    group "postgres"
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
  end

  ruby_block "wait-for-db-slave-mount" do
    block do
      until system("ls -l /db/postgresql")
        sleep 3
        Array(resources(:mount => "/db")).each do |resource|
          resource.run_action(:mount)
        end
      end
    end
  end
end
