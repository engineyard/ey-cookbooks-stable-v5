#
# Cookbook Name:: sequelizejs
# Recipe:: default
#
# Generate config/config.json to store database credentials.

if ['solo', 'app_master', 'app', 'util'].include?(node['dna']['instance_role'])

  node['dna']['applications'].each do |app_name, data|

    ey_cloud_report "sequelizejs" do
      message "Sequelize - Generate config/config.json"
    end

    database_name = node['dna']['engineyard']['environment']['apps']
      .select{|a| a.name == app_name}.first['database_name']

    # generate config/config.json
    template "/data/#{app_name}/shared/config/config.json" do
      owner node[:owner_name]
      group node[:owner_name]
      mode 0644
      source 'config.json.erb'
      variables({
        :environment => node[:dna][:environment][:framework_env],
        :dialect => node[:sequelizejs][:dialect],
        :database => database_name,
        :username => node['dna']['engineyard']['environment']['ssh_username'],
        :password => node['dna']['engineyard']['environment']['ssh_password'],
        :host => node['dna']['db_host']
      })
    end

  end

end
