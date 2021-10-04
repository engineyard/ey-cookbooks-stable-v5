require 'mixlib/shellout'

managed_template "/etc/.mysql.backups.yml" do
  owner 'root'
  group 'root'
  mode 0600
  source "backups.yml.erb"
  variables({
    :dbuser => node.engineyard.environment['db_admin_username'],
    :dbpass => node.engineyard.environment['db_admin_password'],
    :log_coordinates => db_host_is_rds? ? false : true,
    :keep   => node.dna['backup_window'] || 14,
    :id     => node.dna['aws_secret_id'],
    :key    => node.dna['aws_secret_key'],
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

is_backup_instance = if node['db_backup']['mysql']['backup_slave']
  ['db_slave'].include?(node.dna['instance_role']) && node['db_backup']['mysql']['db_slave_name'] == node['dna']['name']
else
  ['db_master','solo'].include?(node.dna['instance_role'])
end

if node.dna['backup_window'] != 0 && is_backup_instance
  encryption_command = @encryption_command
  backup_command = "eybackup -e mysql #{encryption_command} >> /var/log/eybackup.log 2>&1"

  cron "mysql" do
    command backup_command
    month   '*'
    weekday '*'
    day     '*'
    hour    node['backup_hour']     # this attribute is set by ey-base/attributes/snapshot_and_backup_intervals.rb
    minute  node['backup_minute']
  end
end
