if node.engineyard.instance.stonith_config
  # new stonith-api config
  update_file "/etc/stonith.yml" do
    action :rewrite
    owner 'root'
    group 'root'
    mode 0644
    body(node.engineyard.instance.stonith_config.to_hash.to_yaml)
  end
else
  # legacy stonith.yml
  template "/etc/stonith.yml" do
    owner 'root'
    group 'root'
    mode 0644
    source "stonith.yml.erb"
    variables({
      :aws_secret_id      => node.dna['aws_secret_id'],
      :aws_secret_key     => node.dna['aws_secret_key'],
      :endpoint_token     => node.dna['instance']['awsm_token'],
      :endpoint_uri       => node.dna.environment.stonith_endpoint,
      'meta_data_hostname' => node.dna['master_app_server']['private_dns_name'],
      :meta_data_id       => node.dna['instance']['id'],
      'monitor_host'       => node.dna['master_app_server']['private_dns_name'],
      :redis_host         => node.dna[:db_host],
      :redis_port         => 6380,
    })
  end
end

inittab "ey" do
  command "/usr/local/ey_resin/bin/stonith-cron >> /var/log/stonith-cron.log 2>&1"
end

logrotate "ey-monitor" do
  files "/var/log/ey-monitor.log /var/log/stonith.log /var/log/stonith-cron.log"
  copy_then_truncate true
end

execute "let init restart stonith" do
  command "pkill -f stonith-cron"

  only_if "pgrep -f stonith-cron"
end

execute "let init restart legacy ey-monitor" do
  command "pkill -f ey-monitor"

  only_if "pgrep -f ey-monitor"
end
