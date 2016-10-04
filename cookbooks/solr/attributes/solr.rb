solr_instance_name = 'solr'
default['solr'] = {
  'java_version'          => '3.0.1',
  'java_eselect_version'  => 'icedtea-bin-8',
  'solr_version'          => '6.1.0',
  'core_name'             => 'default',
  'solr_instance_name'    => solr_instance_name,
  'is_solr_instance'      => (
    node['dna']['instance_role'] == 'solo') ||
    (node['dna']['instance_role'] == 'util' && node['dna']['name'] == solr_instance_name
  )
}
