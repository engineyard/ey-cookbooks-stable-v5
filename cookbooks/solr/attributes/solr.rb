default['solr'].tap do |solr|
  solr['java_version'] = '3.0.1'
  solr['java_eselect_version']  = 'icedtea-bin-8'
  solr['solr_version'] = '6.1.0'
  solr['core_name'] = 'default'

  # Run Solr on a named util instance
  # This is the default
  solr['is_solr_instance'] = (node['dna']['instance_role'] == 'util' && node['dna']['name'] == 'solr')

  # Run Solr on a solo instance
  # Not recommended for production environments
  #solr['is_solr_instance'] = (node['dna']['instance_role'] == 'solo')
end
