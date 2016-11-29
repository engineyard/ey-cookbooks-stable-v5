default['solr'].tap do |solr|
  solr['java_version'] = '3.0.1'
  solr['java_eselect_version']  = 'icedtea-bin-8'
  solr['solr_version'] = '6.1.0'
  solr['core_name'] = 'default'
  solr['port'] = '8983'

  # Run Solr on a named util instance
  # This is the default
  solr['is_solr_instance'] = (node['dna']['instance_role'] == 'util' && node['dna']['name'] == 'solr')
  solr['solr_instance_name'] = 'solr'

  # Run Solr on a solo instance
  # Not recommended for production environments
  #solr['is_solr_instance'] = (node['dna']['instance_role'] == 'solo')

  # monit memory limit for the Solr process, in MB
  solr['memory_limit'] = 1024
  # Terminate the Solr process if it exceeds the limit for this number of cycles
  # The default monit cycle is 30 seconds
  solr['memory_limit_cycles'] = 4
end
