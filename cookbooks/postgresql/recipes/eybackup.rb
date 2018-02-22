template "/etc/.postgresql.backups.yml" do
  owner 'root'
  group 'root'
  mode 0600
  backup 0
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

# remove AMI MySQL backup schedule
cron "mysql" do
  action :delete
  only_if {['solo', 'db_master'].include?(node['dna']['instance_role'])}
end


if ['solo', 'db_master'].include?(node['dna']['instance_role'])
  cron "postgresql" do
    minute    node['dna']['backup_minute']
    hour      node['dna']['backup_hour']
    day       '*'
    month     '*'
    weekday   '*'
    command   '/usr/local/ey_resin/bin/eybackup -e postgresql --quiet'
    not_if { node['dna']['backup_window'].to_s == '0' }
    action :create
  end
end
