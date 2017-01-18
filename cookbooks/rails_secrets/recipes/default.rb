if ['app_master', 'app', 'util', 'solo'].include?(node['dna']['instance_role'])
  app_names = node['dna']['applications'].keys
  app_names.each do |app|
    template "/data/#{app}/shared/config/secrets.yml"do
      cookbook 'custom-rails_secrets'
      source "secrets.yml.#{app}.erb"
      owner node['owner_name']
      group node['owner_name']
      mode 0655
      backup 0
    end
  end
end
