default['elasticsearch'].tap do |elasticsearch|
  # Run Elasticsearch on util instances named elasticsearch_*
  # This is the default
  elasticsearch['is_elasticsearch_instance'] = ( node['dna']['instance_role'] == 'util' && node['dna']['name'].include?('elasticsearch_') )

  # Run Elasticsearch on a solo or app_master instance
  # Not recommended for production environments
  #elasticsearch['is_elasticsearch_instance'] = ( ['solo', 'app_master'].include?(node['dna']['instance_role']) )

  # Set this to true if you're running more than one elasticsearch instance
  # Set to false if you're running on a solo or app_master
  elasticsearch['configure_cluster'] = true

  # Elasticsearch version to install
  elasticsearch['version'] = '2.4.0'

  # Gentoo Java package name to use
  elasticsearch['java_package_name'] = 'dev-java/icedtea-bin'

  # Which version of the java package to use
  elasticsearch['java_version'] = '3.0.1'
  
  # After installing the Java version we also need to eselect it
  # The version below tells chef what java package to specify in eselect
  elasticsearch['java_eselect_version'] = 'icedtea-bin-8'

  # Elasticsearch cluster name
  elasticsearch['clustername'] = node['dna']['environment']['name']

  # Where to store the ES index
  elasticsearch['home'] = '/data/elasticsearch'

  # Elasticsearch configuration parameters
  elasticsearch['heap_size'] = 1000
  elasticsearch['fdulimit'] = nil
  elasticsearch['defaultreplicas'] = 1
  elasticsearch['defaultshards'] = 6
end
