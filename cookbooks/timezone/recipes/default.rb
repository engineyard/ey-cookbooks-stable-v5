# It has to match a corresponding file under /usr/share/zoneinfo/
timezone = node['timezone']['zone'] || "UTC"
more_services = node['timezone']['services']

has_nginx = ['solo','app','app_master'].include?(node['dna']['instance_role'])

service "vixie-cron"
service "sysklogd"
service "nginx"

more_services.each do |s|
  service "#{s}"
end

link "/etc/localtime" do
  to "/usr/share/zoneinfo/#{timezone}"

  notifies :restart, 'service[vixie-cron]', :delayed
  notifies :restart, 'service[sysklogd]', :delayed
  if has_nginx
    notifies :restart, 'service[nginx]', :delayed
  end

  more_services.each do |s|
    notifies :restart, "service[#{s}]", :delayed
  end

  not_if "readlink /etc/localtime | grep -q '#{timezone}$'"
end
