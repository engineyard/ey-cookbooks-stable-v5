#
# Cookbook Name:: nullmailer
# Recipe:: default
#

# Uninstall ssmtp package if installed
#
package 'mail-mta/ssmtp' do
  action :remove
end

# install packages
package 'mail-mta/nullmailer' do
  version '1.13-r5'
end

# service start
service 'nullmailer' do
  supports status: true, restart: true
  action [ :enable, :start ]
end

# configure:
file '/etc/nullmailer/me' do
  content node['nullmailer']['me']
  user 'root'
  group 0
  mode 00644
  action :create
  only_if { node['nullmailer']['configure']['me'] }
  notifies :restart, "service[nullmailer]", :delayed
end

%w{adminaddr idhost defaulthost helohost defaultdomain pausetime sendtimeout}.each do |control_file|
  file "/etc/nullmailer/#{control_file}" do
    content node['nullmailer'][control_file].to_s
    user 'root'
    group 0
    mode 00644
    action :create
    not_if { node['nullmailer'][control_file].nil? }
    notifies :restart, "service[nullmailer]", :delayed
  end
end

remote = "#{node['nullmailer']['relayhost']} #{node['nullmailer']['relay_proto']}"

file '/etc/nullmailer/remotes' do
  content(node['nullmailer']['relay_options'].inject(remote) do |options, (option, value)|
    options += " --#{option}" if value
    options += "=#{value}" if value.is_a?(String) or value.is_a?(Fixnum)
    options
  end)
  user 'root'
  group 'nullmail'
  mode 00600
  action :create
  only_if { node['nullmailer']['configure']['remotes'] }
  notifies :restart, "service[nullmailer]", :delayed
end

