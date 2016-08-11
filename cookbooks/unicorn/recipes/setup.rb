ey_cloud_report "unicorn" do
  message "processing unicorn - setup"
end

directory "/var/log/engineyard/unicorn" do
  owner node.engineyard.environment.ssh_username
  group node.engineyard.environment.ssh_username
  mode 0755
end

directory "/var/run/engineyard" do
  owner node.engineyard.environment.ssh_username
  group node.engineyard.environment.ssh_username
  action :create
  mode 0755
end

node.engineyard.apps.each do |app|

  directory "/var/run/unicorn/#{app.name}" do
    owner node.engineyard.environment.ssh_username
    group node.engineyard.environment.ssh_username
    mode 0755
    recursive true
  end

end
