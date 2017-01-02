kubernetes_master_instance = node['dna']['engineyard']['environment']['instances'].find { |instance| instance['role'] == 'app_master' }
if kubernetes_master_instance.nil?
  raise "Kubernetes master instance does not exist"
end

if environment_metadata = node['dna']['engineyard']['environment']['components'].find{|c| c['key'] == 'environment_metadata'}
  if environment_metadata['kubernetes_aws_access_key_id'].to_s.empty? || environment_metadata['kubernetes_aws_secret_access_key'].to_s.empty?
    raise "Contact Support to add kubernetes_aws_access_key_id and kubernetes_aws_secret_access_key to EY Cloud metadata" 
  end
end

default['kubernetes'] = {
  'version' => '1.5.1',
  'aws_access_key_id' => environment_metadata['kubernetes_aws_access_key_id'],
  'aws_secret_access_key' => environment_metadata['kubernetes_aws_secret_access_key'],
  'master_hostname' => kubernetes_master_instance['private_hostname'],
  'kubernetes_cluster_tag' => 'kubernetes', # Change this if you want to use a different cluster name. Usually that's done if you want to set up a second kubernetes cluster on the same VPC.
  'kubernetes_service_ip' => '10.254.0.1',
  'service_cluster_ip_range' => '10.254.0.0/16',
  'vpc_cidr' => '172.31.0.0/16' # Default on EY Cloud. Do not change this.
}
