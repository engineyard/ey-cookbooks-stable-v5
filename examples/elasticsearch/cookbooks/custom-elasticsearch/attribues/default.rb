# Modify the variables below to change how Elasticsearch will be installed
# See cookbooks/elasticsearch/attributes/default.rb for the complete list of configurable variables

# Run Elasticsearch on util instances named elasticsearch_*
# This is the default
#elasticsearch['is_elasticsearch_instance'] = ( node['dna']['instance_role'] == 'util' && node['dna']['name'].include?('elasticsearch_') )

# Run Elasticsearch on a solo or app_master instance
# Not recommended for production environments
#elasticsearch['is_elasticsearch_instance'] = ( ['solo', 'app_master'].include?(node['dna']['instance_role']) )

# Set this to true if you're running more than one elasticsearch instance
# Set to false if you're running on a solo or app_master
#elasticsearch['configure_cluster'] = false
