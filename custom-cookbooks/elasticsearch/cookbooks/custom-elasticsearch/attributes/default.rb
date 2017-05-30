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

  # Where to download and extract the installer
  elasticsearch['tmp_dir'] = '/tmp'

  # Elasticsearch version to install
  # Go to https://www.elastic.co/downloads/past-releases to see the available version
  #elasticsearch['version'] = '5.5.0'
  elasticsearch['version'] = '2.4.4'
  # This is the SHA256 checksum. Note that this is different from the SHA1 checksum in the Elastic website
  # To generate the SHA256 checksum, download the file and then run:
  # - Linux: sha256sum <zipfile>
  # - OSX: shasum -a 256 <zipfile>
  #elasticsearch['checksum'] = '02d9b16334ca97eaaab308bb65743ba18249295d4414f6967c2daf13663cf01d'   # checksum for 5.5.0
  elasticsearch['checksum'] = 'bee3ca3d5b2103e09b18e1791d1cc504388b992cc4ebf74869568db13c3d4372'  # checksum for 2.4.4

  # Use this URL for the 5.x.x versions
  #elasticsearch['download_url'] = "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-#{elasticsearch['version']}.zip"
  # Use this URL for the 2.4.x versions
  elasticsearch['download_url'] = "https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/zip/elasticsearch/#{elasticsearch['version']}/elasticsearch-#{elasticsearch['version']}.zip"

  # Gentoo Java package name to use
  elasticsearch['java_package_name'] = 'dev-java/icedtea-bin'

  # Which version of the java package to use
  elasticsearch['java_version'] = '3.3.0'

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

  # JVM Options, will be used to populate /etc/elasticsearch/jvm.options
  # For guidelines on how to calculate the optimal JVM memory settings,
  # see https://www.elastic.co/guide/en/elasticsearch/reference/master/heap-size.html
  elasticsearch['jvm_options'] = {
    :Xms => '2g',
    :Xmx => '2g',
    :Xss => '1m'
  }
end
