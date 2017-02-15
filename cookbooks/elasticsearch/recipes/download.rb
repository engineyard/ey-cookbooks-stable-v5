ES = node['elasticsearch']
download_url = ES['download_url']

if ES['is_elasticsearch_instance']
  Chef::Log.info "Downloading Elasticsearch v#{ES['version']}"
  remote_file "#{ES['tmp_dir']}/elasticsearch-#{ES['version']}.zip" do
    source download_url
    mode "0644"
    action :create_if_missing
    checksum ES['checksum']
  end
end
