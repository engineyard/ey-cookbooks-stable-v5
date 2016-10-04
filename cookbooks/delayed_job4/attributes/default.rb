worker_count = if node[:dna][:instance_role] == 'solo'
                 1
               else
                 case node['ec2']['instance_type']
                 when 'm3.medium' then 2
                 when 'm3.large' then 4
                 when 'm3.xlarge' then 8
                 when 'm3.2xlarge' then 8
                 when 'c3.large' then 4
                 when 'c3.xlarge' then 8
                 when 'c3.2xlarge' then 8
                 when 'm4.large' then 4
                 when 'm4.xlarge' then 8
                 when 'm4.2xlarge' then 8
                 when 'c4.large' then 4
                 when 'c4.xlarge' then 8
                 when 'c4.2xlarge' then 8
                 else # default
                   2
                 end
               end

default['delayed_job4'] = {
  'is_dj_instance' => (node['dna']['instance_role'] == 'solo') || (node['dna']['instance_role'] == 'util' && node['dna']['name'] == 'delayed_job'),
  'applications' => node[:dna][:applications].map{|app_name, data| app_name},
  'worker_count' => worker_count
}
