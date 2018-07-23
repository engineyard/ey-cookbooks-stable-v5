app_name = node.dna[:applications].keys.first

default['papertrail'].tap do |papertrail|
  papertrail['syslog_ng_version']      = '3.7.3'
  papertrail['remote_syslog_version']  = 'v0.16'
  papertrail['remote_syslog_filename'] = 'remote_syslog_linux_amd64.tar.gz'
  papertrail['remote_syslog_checksum'] = 'be208e650e910106bc9d6c954807c875b22cd9fbe005aa59e0aad0ed13b0c6b6'
  papertrail['port']                   = 111111111111111 # YOUR PORT HERE
  papertrail['destination_host']       = 'HOST.papertrailapp.com' # YOUR HOST HERE
  papertrail['hostname']               = [app_name, node.dna[:instance_role], `hostname`.chomp].join('_')
  papertrail['other_logs']             = [
    '/var/log/engineyard/nginx/*log',
    '/var/log/engineyard/apps/*/*.log',
    '/var/log/mysql/*.log',
    '/var/log/mysql/mysql.err',
  ]
  papertrail['exclude_patterns']      = [  
    '400 0 "-" "-" "-', # seen in ssl access logs
  ]
  # Install Papertrail to all instances by default
  papertrail['is_papertrail_instance'] = true
end

