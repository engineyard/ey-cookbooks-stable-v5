execute "install aws cli" do
  cwd "/tmp"
  command "curl https://s3.amazonaws.com/aws-cli/awscli-bundle.zip -o awscli-bundle.zip && unzip awscli-bundle.zip && ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws"
  not_if { File.exist?('/usr/local/bin/aws') }
end

execute "create aws tag on route table" do
  command "region=$(curl -s 169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/[a-z]$//'); route_table_id=$(aws --region=$region ec2 describe-route-tables --filters Name=route.destination-cidr-block,Values=#{node['kubernetes']['vpc_cidr']} --query 'RouteTables[].RouteTableId' --output text); aws --region=$region ec2 create-tags --resources=$route_table_id --tags Key=KubernetesCluster,Value=#{node['kubernetes']['kubernetes_cluster_tag']}"
  not_if { File.exist?('/data/skip_kubernetes_tags') }
end
