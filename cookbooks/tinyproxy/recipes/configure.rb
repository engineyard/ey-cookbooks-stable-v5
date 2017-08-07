# Change app_name based on your application name
app_name = 'todo'
proxy_port = node['tinyproxy']['port']

# Write down the IP address and port used by the tinyproxy host
# so that web workers or background job workers know how to use tinyproxy

def tinyproxy_host
  case node['tinyproxy']['install_type']
  when 'NAMED_UTIL'
    node.dna.utility_instances.
      select{ |i| i.name == node['tinyproxy']['utility_name'] }.
      map{ |i| i.hostname }.
      first
  when 'APP_MASTER'
    node.engineyard.environment.instances.
      select{ |i| 'app_master' == i.role }.
      map{ |i| i.private_hostname}.
      first
  end
end

hostname = tinyproxy_host
if ['solo', 'app_master', 'app', 'util'].include?(node['dna']['instance_role'])
  template "/data/#{app_name}/shared/config/tinyproxy.yml" do
    owner 'deploy'
    group 'deploy'
    mode 0644
    source 'tinyproxy.yml.erb'
    variables({
      :hostname => hostname,
      :port => proxy_port
    })
  end
end

