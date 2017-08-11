require 'mixlib/shellout'

managed_template "/etc/.postgresql.backups.yml" do
  owner 'root'
  group 'root'
  mode 0600
  source "backups.yml.erb"
  variables({
    :dbuser => node.dna['users'].first['username'],
    :dbpass => node.dna['users'].first['password'],
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

has_backups_enabled  = node.dna['backup_window'] != 0
db_slaves_available  = node.dna['db_slaves'].any?
is_db_master_or_solo = ['db_master','solo'].include?(node.dna['instance_role'])
is_db_slave          = 'db_slave' == node.dna['instance_role']

# The backup target is the first db-slave, we do this to avoid multiple db-slaves doing backups
is_backup_target = node.dna['db_slaves'].first == (node['ec2'] && node['ec2']['local_hostname'] ? node['ec2']['local_hostname'] : hostname.stdout)

if has_backups_enabled && (db_slaves_available && is_db_slave && is_backup_target || !db_slaves_available && is_db_master_or_solo)
  encryption_command = @encryption_command

  cron 'postgresql' do
    command "eybackup -e postgresql #{encryption_command} >> /var/log/eybackup.log 2>&1"
    month   '*'
    weekday '*'
    day     '*'
    hour    node['backup_hour']     # this attribute is set by ey-base/attributes/snapshot_and_backup_intervals.rb
    minute  node['backup_minute']
  end
else
  cron 'postgresql' do
    user   cronjob_user
    action :delete
  end
end
