include_recipe "node::common"

execute "install pm2" do
  command "npm install -g pm2"
  notifies :create, "link[/usr/bin/pm2]"
end

link "/usr/bin/pm2" do
  to "/opt/nodejs/current/bin/pm2"
  # only_if { File.exist?("/opt/nodejs/current/bin/pm2") }
  # not_if { File.exists?("/usr/bin/pm2") }
  notifies :run, "execute[start pm2 at boot]"
  action :nothing
end

execute "start pm2 at boot" do
  command "pm2 startup openrc"
  # only_if { ::File.exists?("/usr/bin/pm2") }
  action :nothing
end

template "/etc/monit.d/pm2.monitrc" do
  source "pm2.monitrc.erb"
  owner "root"
  group "root"
  mode 0644
  variables({
    :user => node[:owner_name]
  })
end

worker_count = get_pool_size

node.engineyard.apps.each_with_index do |app, app_index|

  app_name = app.name

  template "/engineyard/bin/app_#{app_name}" do
    source "app_control.sh.erb"
    owner node["owner_name"]
    group node["owner_name"]
    backup 0
    mode 0755
    variables(
      :app_name => app_name,
      :worker_count => worker_count
    )
  end
end
