bash 'install ey_node_app_info' do
  code "/usr/bin/npm install -g ey_node_app_info"
end

file "/usr/lib/node_modules/ey_node_app_info/bin/ey_node_app_info" do
  action :delete
end

link "/usr/local/bin/ey_node_app_info" do
  to "/opt/nodejs/#{node['nodejs']['version']}/bin/ey_node_app_info"
end
