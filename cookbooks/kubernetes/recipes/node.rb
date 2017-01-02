=begin
execute "add docker key and source" do
  command "echo deb https://apt.dockerproject.org/repo ubuntu-trusty main > /etc/apt/sources.list.d/docker.list"
  command "apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D"
  command "apt-get update"
end

package "docker-engine"
=end

include_recipe "kubernetes::aws_credentials"

%w[kubelet kube-proxy kubectl].each do |k8s_file|
  remote_file "/usr/bin/#{k8s_file}" do
    source "https://storage.googleapis.com/kubernetes-release/release/v#{node['kubernetes']['version']}/bin/linux/amd64/#{k8s_file}"
    mode '0755'
  end
end

%w[kubelet kube-proxy].each do |k8s|
  execute "service-#{k8s}-restart" do
    command "service #{k8s} restart"
    action :nothing
  end
  
  template "/etc/default/#{k8s}" do
    source "#{k8s}.erb"
    variables :hostname => node['ec2']['local_hostname'], :kubernetes_master_hostname => node['kubernetes']['master_hostname']
    notifies :run, resources(:execute => "service-#{k8s}-restart"), :delayed
  end

  template "/etc/systemd/system/#{k8s}.service" do
    source "#{k8s}.service.erb"
    mode "0755"
    notifies :run, resources(:execute => "service-#{k8s}-restart"), :delayed
  end

=begin
  execute "start kubernetes component #{k8s}" do
    command "service #{k8s} start"
    not_if "service #{k8s} status"
  end
=end
end

