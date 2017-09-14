ES = node['elasticsearch']

if node['dna']['utility_instances'].empty?
  Chef::Log.info "No utility instances found"
else
  elasticsearch_instances = []
  elasticsearch_expected = 0
  node['dna']['utility_instances'].each do |elasticsearch|
    if elasticsearch['name'].include?("elasticsearch")
      elasticsearch_expected = elasticsearch_expected + 1 unless node['dna']['fqdn'] == elasticsearch['hostname']
      elasticsearch_instances << "#{elasticsearch['hostname']}:9300" unless node['dna']['fqdn'] == elasticsearch['hostname']
    end
  end

  template "/usr/lib/elasticsearch-#{ES['version']}/config/elasticsearch.yml" do
    source "elasticsearch.yml.erb"
    owner "elasticsearch"
    group "nogroup"
    variables(
      :elasticsearch_instances => elasticsearch_instances.join('", "'),
      :elasticsearch_defaultreplicas => ES['defaultreplicas'],
      :elasticsearch_expected => elasticsearch_expected,
      :elasticsearch_defaultshards => ES['defaultshards'],
      :elasticsearch_clustername => ES['clustername'],
      :elasticsearch_host => node['fqdn']
    )
    mode 0600
    backup 0
  end
end
