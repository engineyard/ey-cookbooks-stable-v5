#
# Cookbook Name:: cdn_distribution
# Recipe:: default
#

if %w[solo app app_master].include?(node['dna']['instance_role'])
  ssh_username = node['dna']['engineyard']['environment']['ssh_username']

  node.engineyard.apps.each do |app|
    cdn_distribution = app.metadata('cdn_distribution', nil)

    if cdn_distribution
      base_dir = "/data/#{app.name}/shared/config/initializers"

      directory base_dir do
        owner ssh_username
        group ssh_username
        recursive true
      end

      template "#{base_dir}/cdn.rb" do
        source "cdn.initializer.erb"
        owner ssh_username
        group ssh_username
        mode 0744
        variables(:asset_host => cdn_distribution['domain'])
      end
    end
  end
end
