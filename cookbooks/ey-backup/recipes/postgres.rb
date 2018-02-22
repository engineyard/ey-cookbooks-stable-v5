require 'mixlib/shellout'

template "/etc/.postgresql.backups.yml" do
  owner 'root'
  group 'root'
  mode 0600
  source "backups.yml.erb"
  variables({
    :dbuser => node.engineyard.environment['db_admin_username'],
    :dbpass => node.engineyard.environment['db_admin_password'],
    :keep   => node['dna']['backup_window'] || 14,
    :id     => node['dna']['aws_secret_id'],
    :key    => node['dna']['aws_secret_key'],
    :env    => node.engineyard.environment['name'],
    :region => node.engineyard.environment.region,
    :backup_bucket => node.engineyard.environment.backup_bucket,
    :databases => node.engineyard.apps.map {|app| app.database_name }
  })
end

@encryption_command =  ""

node.engineyard.environment['apps'].each do |app|
	app['components'].each do |component|
	  if component['key'] == 'encrypted_backup'
	    include_recipe 'ey-backup::encrypted'

	    @long_key_id =  ""

	    gpg_keys = Mixlib::ShellOut.new("gpg --list-keys --with-colon")
	    gpg_keys.run_command
	    gpg_keys.stdout.each_line do |line|
        if line[0..2] == 'pub'
          @long_key_id = line.split(':')[4]
        end
      end

  	  @encryption_command = "-k #{@long_key_id}" unless @long_key_id.empty?
    end
	end
end

if node['dna']['db_slaves'].empty? && node['dna']['backup_window'] != 0
  # No slaves detected, put the backup on the solo/db_master if backups are enabled
  if ['db_master','solo'].include?(node['dna']['instance_role'])
    encryption_command = @encryption_command

    backup_cron "postgresql" do
      command "eybackup -e postgresql #{encryption_command} >> /var/log/eybackup.log 2>&1"
      month   '*'
      weekday '*'
      day     '*'
      hour    node['backup_hour']       # this attribute is set by ey-base/attributes/snapshot_and_backup_intervals.rb
      minute  node['backup_minute']
    end
  end
  # Slaves detected, put them on the db_slave if backups are enabled
else
  if ['db_slave'].include?(node['dna']['instance_role']) && node['dna']['backup_window'] != 0
    db_slave1_fqdn=node['dna']['db_slaves'].first
    encryption_command = @encryption_command

    hostname = Mixlib::ShellOut.new("hostname")
    hostname.run_command

    cron "postgresql" do
      command "eybackup -e postgresql #{encryption_command} >> /var/log/eybackup.log 2>&1"
      month   '*'
      weekday '*'
      day     '*'
      hour    node['backup_hour']       # this attribute is set by ey-base/attributes/snapshot_and_backup_intervals.rb
      minute  node['backup_minute']
      only_if {(node['ec2'] && node['ec2']['local_hostname'] ? node['ec2']['local_hostname'] : hostname.stdout)  == db_slave1_fqdn}
    end
  else
    cron "postgresql" do
      action :delete
    end
  end
end
