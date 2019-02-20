worker_count = if node[:dna][:instance_role] == 'solo'
                 1
               else
                 case node['ec2']['instance_type']
                 when 't2.micro' then 1
                 when 't2.small' then 1
                 when 't2.xlarge' then 4
                 when 't2.2xlarge' then 8
                 when 'm3.large' then 4
                 when 'm3.xlarge' then 8
                 when 'm3.2xlarge' then 8
                 when 'c3.large' then 4
                 when 'c3.xlarge' then 8
                 when 'c3.2xlarge' then 8
                 when 'c3.4xlarge' then 16
                 when 'c3.8xlarge' then 32
                 when 'm4.large' then 4
                 when 'm4.xlarge' then 8
                 when 'm4.2xlarge' then 8
                 when 'm4.4xlarge' then 16
                 when 'm4.10xlarge' then 40
                 when 'm4.16xlarge' then 64
                 when 'c4.large' then 4
                 when 'c4.xlarge' then 8
                 when 'c4.2xlarge' then 8
                 when 'c4.4xlarge' then 16
                 when 'c4.8xlarge' then 32
                 when 'r3.large' then 4
                 when 'r3.xlarge' then 8
                 when 'r3.2xlarge' then 16
                 when 'r3.4xlarge' then 32
                 when 'r3.8xlarge' then 64
                 when 'r4.large' then 4
                 when 'r4.xlarge' then 8
                 when 'r4.2xlarge' then 16
                 when 'r4.4xlarge' then 32
                 when 'r4.8xlarge' then 64
                 when 'r4.16xlarge' then 128

                 #gen5 instances
                 when 't3.micro' then 2
                 when 't3.small' then 2
                 when 't3.medium' then 2
                 when 't3.large' then 2
                 when 't3.xlarge' then 4
                 when 't3.2xlarge' then 8
                 when 'm5.large' then 2
                 when 'm5.xlarge' then 4
                 when 'm5.2xlarge' then 8
                 when 'm5.4xlarge' then 16
                 when 'm5.12xlarge' then 48
                 when 'm5.24xlarge' then 96
                 when 'm5a.large' then 2
                 when 'm5a.xlarge' then 4
                 when 'm5a.2xlarge' then 8
                 when 'm5a.4xlarge' then 16
                 when 'm5a.12xlarge' then 48
                 when 'm5a.24xlarge' then 96
                 when 'm5d.large' then 2
                 when 'm5d.xlarge' then 4
                 when 'm5d.2xlarge' then 8
                 when 'm5d.4xlarge' then 16
                 when 'm5d.12xlarge' then 48
                 when 'm5d.24xlarge' then 96
                 when 'c5.large' then 2
                 when 'c5.xlarge' then 4
                 when 'c5.2xlarge' then 8
                 when 'c5.4xlarge' then 16
                 when 'c5.9xlarge' then 36
                 when 'c5.18xlarge' then 72
                 when 'c5d.large' then 2
                 when 'c5d.xlarge' then 4
                 when 'c5d.2xlarge' then 8
                 when 'c5d.4xlarge' then 16
                 when 'c5d.9xlarge' then 36
                 when 'c5d.18xlarge' then 72
                 when 'r5.large' then 2
                 when 'r5.xlarge' then 4
                 when 'r5.2xlarge' then 8
                 when 'r5.4xlarge' then 16
                 when 'r5.12xlarge' then 48
                 when 'r5.24xlarge' then 96
                 when 'r5a.large' then 2
                 when 'r5a.xlarge' then 4
                 when 'r5a.2xlarge' then 8
                 when 'r5a.4xlarge' then 16
                 when 'r5a.12xlarge' then 48
                 when 'r5a.24xlarge' then 96
                 when 'r5d.large' then 2
                 when 'r5d.xlarge' then 4
                 when 'r5d.2xlarge' then 8
                 when 'r5d.4xlarge' then 16
                 when 'r5d.12xlarge' then 48
                 when 'r5d.24xlarge' then 96
                 when 'i3.large' then 2
                 when 'i3.xlarge' then 4
                 when 'i3.2xlarge' then 8
                 when 'i3.4xlarge' then 16
                 when 'i3.8xlarge' then 32
                 when 'i3.16xlarge' then 64


                 else # default
                   2
                 end
               end

default['delayed_job4'] = {
  'is_dj_instance' => (node['dna']['instance_role'] == 'solo') || (node['dna']['instance_role'] == 'util' && node['dna']['name'] == 'delayed_job'),
  'applications' => node[:dna][:applications].map{|app_name, data| app_name},
  'worker_count' => worker_count,
  'worker_memory' => 300
}
