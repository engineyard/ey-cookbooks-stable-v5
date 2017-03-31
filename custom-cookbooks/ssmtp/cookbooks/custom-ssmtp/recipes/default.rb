#
# Cookbook Name:: ssmtp
# Recipe:: default
#

# Modify the line below if you don't need to install ssmtp on all instances
if ['solo', 'app', 'util', 'app_master', 'db_master', 'db_slave'].include?(node['dna']['instance_role'])

  directory "/etc/ssmtp" do
    recursive true
    action :delete
  end

  directory "/data/ssmtp" do
    owner "deploy"
    group "deploy"
    mode "0755"
    action :create
    not_if "test -d /data/ssmtp"
  end

  cookbook_file '/data/ssmtp/ssmtp.conf' do
    source 'ssmtp.conf'
    owner 'deploy'
    group 'deploy'
    mode '0755'
    action :create
  end

  link "/etc/ssmtp" do
    to '/data/ssmtp'
  end

end
