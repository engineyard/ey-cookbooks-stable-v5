service "sysklogd" do
  action :enable
end

package "sysklogd" do
  action :install
  version at_least_version(node['sysklogd']['version'])
  notifies :restart, 'service[sysklogd]'
end
