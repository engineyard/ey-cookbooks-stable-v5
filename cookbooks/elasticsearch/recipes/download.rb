ES = node['elasticsearch']
download_url = "https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/zip/elasticsearch/#{ES['version']}/elasticsearch-#{ES['version']}.zip"

if ES['is_elasticsearch_instance']
  Chef::Log.info "Downloading Elasticsearch v#{ES['version']}"
  remote_file "#{Chef::Config[:file_cache_path]}/elasticsearch-#{ES['version']}.zip" do
    source download_url
    mode "0644"
    action :create_if_missing
  end
end
