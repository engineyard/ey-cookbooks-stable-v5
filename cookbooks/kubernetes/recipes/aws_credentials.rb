directory "/root/.aws" do
  action :create
  owner "root"
  group "root"
  mode 0755 
end

template "/root/.aws/credentials" do
  source "aws_credentials.erb"
  variables :aws_access_key_id => node['kubernetes']['aws_access_key_id'], :aws_secret_access_key => node['kubernetes']['aws_secret_access_key']
end

template "/root/.aws/env" do
  source "aws_env.erb"
  variables :aws_access_key_id => node['kubernetes']['aws_access_key_id'], :aws_secret_access_key => node['kubernetes']['aws_secret_access_key']
end
