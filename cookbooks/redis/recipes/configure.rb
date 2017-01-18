#
# Cookbook Name:: redis
# Recipe:: configure
#

if ['solo', 'app', 'app_master', 'util'].include?(node['dna']['instance_role'])
  instances = node['dna']['engineyard']['environment']['instances']
  redis_instance = (node['dna']['instance_role'][/solo/] && instances.length == 1) ?
    instances[0] : instances.find{|i| i['name'] == node['redis']['utility_name']}

  if redis_instance
    ip_address = `ping -c 1 #{redis_instance['private_hostname']} | awk 'NR==1{gsub(/\\(|\\)/,"",$3); print $3}'`.chomp
    host_mapping = "#{ip_address} redis-instance"

    execute "Remove existing redis-instance mapping from /etc/hosts" do
      command "sudo sed -i '/redis-instance/d' /etc/hosts"
      action :run
    end

    execute "Add redis-instance mapping to /etc/hosts" do
      command "sudo echo #{host_mapping} >> /etc/hosts"
      action :run
    end

    node['dna']['applications'].each do |app, data|
      template "/data/#{app}/shared/config/redis.yml"do
        source 'redis.yml.erb'
        owner node['owner_name']
        group node['owner_name']
        mode 0655
        backup 0
        variables({
          'environment' => node['dna']['engineyard']['environment']['framework_env'],
          'hostname' => redis_instance['private_hostname']
        })
      end
    end
  end
end
