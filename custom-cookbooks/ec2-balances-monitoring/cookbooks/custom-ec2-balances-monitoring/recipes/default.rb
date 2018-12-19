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
    :cpu_thresh => node['custom-ec2-balances-monitoring']['cpu_credit_thresholds'],
    :vol_thresh => node['custom-ec2-balances-monitoring']['vol_burst_thresholds']
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

managed_template "/etc/engineyard/collectd-main.conf" do
  source "collectd-main.conf.erb"
  owner 'root'
  group 'root'
  mode 0644
  variables({
    :user => node["owner_name"],
    :original_collectd_conf => "/etc/engineyard/collectd.conf"
  })
end

# Delete the existing collectd inittab entry
inittab "cd" do
  action "delete"
end
# We run collectd from initab using this command
inittab "cd" do
  command "/usr/sbin/collectd -C /etc/engineyard/collectd-main.conf -f"
end

# Kill collectd (violently) to ensure that it has a fresh config
execute "ensure-collectd-has-fresh-config" do
  command 'pkill -9 collectd;true'
end
