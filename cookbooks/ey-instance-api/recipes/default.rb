update_file "/etc/engineyard/instance_api.yml" do
  action :rewrite
  owner 'root'
  group 'root'
  mode 0640
  body((node.engineyard.instance.instance_api_config || {}).to_hash.to_yaml)
end
