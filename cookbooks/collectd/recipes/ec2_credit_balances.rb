if node['collectd']['enable_credit_balances_monitoring'] then

  # Install dependencies
  enable_package 'dev-python/boto3' do
    version '1.3.0'
  end
  enable_package 'dev-python/botocore' do
    version '1.4.19'
  end
  enable_package 'dev-python/jmespath' do
    version '0.9.0'
  end
  package 'dev-python/boto3' do
    action :install
  end
  package 'dev-python/requests' do
    action :install
  end

  managed_template "/engineyard/bin/check_for_ec2_credit_balances.py" do
    source "check_for_ec2_credit_balances.py.erb"
    owner node["owner_name"]
    group node["owner_name"]
    mode 0755
    variables({
      :ec2_thresholds => EC2CreditThresholds.new(node['dna']['engineyard']['environment']['apps'])
    })
  end

  # The script stores internal state here
  directory "/tmp/check_ec2_credit_balances" do
    owner node["owner_name"]
    group node["owner_name"]
    mode 0755
    recursive true
  end

  cookbook_file "/etc/engineyard/ec2credits.types.db" do
    source "ec2credits.types.db"
    owner node["owner_name"]
    group node["owner_name"]
    backup 0
    mode 0644
  end

end # node['collectd']['enable_credit_balances_monitoring']
