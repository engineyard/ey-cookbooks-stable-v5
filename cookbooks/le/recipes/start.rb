
# Cookbook Name:: le
# Recipe:: start
#

# Restart the le agent
service 'logentries' do
  action :restart
end
