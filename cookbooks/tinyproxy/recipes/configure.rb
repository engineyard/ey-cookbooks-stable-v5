# Change app_name based on your application name
app_name = 'todo'
proxy_port = node['tinyproxy']['port']

tinyproxy_instance = node['dna']['engineyard']['environment']['instances'].find { |instance| instance['role'] == 'app_master' }
tinyproxy_host = tinyproxy_instance['private_hostname']
# Write down the IP address and port used by the tinyproxy host
# so that web workers or background job workers know how to use tinyproxy
if ['solo', 'app_master', 'app', 'util'].include?(node['dna']['instance_role'])
  template "/data/#{app_name}/shared/config/tinyproxy.yml" do
    owner 'deploy'
    group 'deploy'
    mode 0644
    source 'tinyproxy.yml.erb'
    variables({
      :hostname => tinyproxy_host,
      :port => proxy_port
    })
  end
end

