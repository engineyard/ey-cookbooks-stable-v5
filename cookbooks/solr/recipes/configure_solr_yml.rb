#
# Cookbook Name:: solr
#

# Create /data/appname/shared/config/solr.yml in solo, app and util instances
username = node['dna']['engineyard']['environment']['ssh_username']
solr_instance = if ('solo' == node['dna']['instance_role'])
  node
else
  node['dna']['utility_instances'].find{ |instance| instance['name'] == node['solr']['solr_instance_name'] }
end

if ['app_master', 'app', 'solo', 'util'].include?(node['dna']['instance_role'])
  node['dna']['applications'].each do |app, data|
    template "/data/#{app}/shared/config/solr.yml" do
      source 'solr.yml.erb'
      owner username
      group username
      mode 0655
      backup 0
      variables({
        environment: node['dna']['environment']['framework_env'],
        hostname: solr_instance['hostname'],
        port: node['solr']['port']
      })
    end
  end
end
