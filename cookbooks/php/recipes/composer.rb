# Report to Cloud dashboard
ey_cloud_report "processing php composer.rb" do
  message "processing php - composer"
end

node['dna']['engineyard']['environment']['apps'].each do |app_data|
  app_env_vars = fetch_environment_variables(app_data)
    app_env_vars.each do |ev|
      if ev[:name] =~ /^EY_COMPOSER/
        custom_composer = ev[:value]

        template "/tmp/composer-install.sh" do
          owner node["owner_name"]
          group node["owner_name"]
          mode "0644"
          source "composer.erb"
          variables({
            :user => node.engineyard.environment.ssh_username,
            :composer => custom_composer
          })
      end
    end
  end
end

template "/tmp/composer-install.sh" do
  owner node["owner_name"]
  group node["owner_name"]
  mode "0644"
  source "composer.erb"
  variables({
    :user => node.engineyard.environment.ssh_username,
    :composer => ""
  })
  not_if { ::File.exists?("/tmp/composer-install.sh") }
end

execute "install composer" do
  command "sh /tmp/composer-install.sh && rm /tmp/composer-install.sh"
end

cookbook_file "/usr/bin/composer" do
  owner node["owner_name"]
  group node["owner_name"]
  mode 0755
  source "composer.sh"
  backup 0
end
