applications_to_deploy.each do |app, data|


  link "/data/#{app}/current/config/mongrel_cluster.yml" do
    to "/data/#{app}/shared/config/mongrel_cluster.yml"
    owner node["owner_name"]
    group node["owner_name"]
    only_if (data[:recipes].include?('mongrel'))
  end


  execute "restart-framework-for-#{app}" do
    command "/engineyard/bin/app_#{app} deploy"
    user node["owner_name"]
  end
end
