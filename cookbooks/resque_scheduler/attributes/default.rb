default['resque_scheduler'] = {
  'is_resque_scheduler_instance' => (node['dna']['instance_role'] == 'solo') || (node['dna']['instance_role'] == 'util' && node['dna']['name'] == 'resque'),
}
