default['papertrail'] = {
  :syslog_ng_version         => '3.7.3',
  :remote_syslog_version     => 'v0.16',
  :remote_syslog_filename    => 'remote_syslog_linux_amd64.tar.gz',
  :remote_syslog_checksum    => '04055643eb1c0db9ec61a67bdfd58697912acb467f58884759a054f6b5d6bb56',
  :port                      => 111111111111111, # YOUR PORT HERE
  :destination_host          => 'HOST.papertrailapp.com', # YOUR HOST HERE
  :hostname                  => [app_name, node.dna[:instance_role], `hostname`.chomp].join('_'),
  :other_logs => [
    '/var/log/engineyard/nginx/*log',
    '/var/log/engineyard/apps/*/*.log',
    '/var/log/mysql/*.log',
    '/var/log/mysql/mysql.err',
  ],
  :exclude_patterns => [
    '400 0 "-" "-" "-', # seen in ssl access logs
  ],
}

