ey_cloud_report "resque" do
  message "resque: app config"
end

node.engineyard.apps.each do |app|
  directory_after_deploy "/data/#{app.name}/current/config"

  link_after_deploy "/data/#{app.name}/current/config/resque.yml" do
    to "/data/#{app.name}/shared/config/resque.yml"
  end

  template "/data/#{app.name}/shared/config/resque.yml" do
    owner   node.engineyard.environment.ssh_username
    group   node.engineyard.environment.ssh_username
    mode    0655
    source "resque.yml.erb"
    variables(
      :host => node.dna['master_app_server']['public_id'],
      :port => 6379
    )
  end
end
