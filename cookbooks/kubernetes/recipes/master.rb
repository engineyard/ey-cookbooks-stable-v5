include_recipe "kubernetes::etcd"
include_recipe "kubernetes::aws_credentials"
include_recipe "kubernetes::aws_tags"

=begin
execute "kubeadm init" do
  command "kubeadm init --token kubey --cloud-provider aws"
end
=end

directory "/data/kubernetes/tls" do
  owner "root"
  group "root"
  mode 0755
  action :create
  recursive true
end

execute "generate key" do
  command "openssl genrsa -out /data/kubernetes/tls/kubernetes-key.pem 2048"
  not_if { File.exist? "/data/kubernetes/tls/kubernetes-key.pem" }
end

%w[kube-apiserver kube-controller-manager kube-scheduler kubectl].each do |k8s_file|
  #execute "copy file to /usr/bin/#{k8s_file}" do
  #  command "cp /tmp/kubernetes-1.3.0/kubernetes/server/bin/#{k8s_file} /usr/bin/#{k8s_file}"
  #end
  remote_file "/usr/bin/#{k8s_file}" do
    source "https://storage.googleapis.com/kubernetes-release/release/v1.4.0/bin/linux/amd64/#{k8s_file}"
    mode '0755'
  end
end

%w[kube-apiserver kube-controller-manager kube-scheduler].each do |k8s|
  execute "service-#{k8s}-restart" do
    command "service #{k8s} restart"
    action :nothing
  end

  template "/etc/default/#{k8s}" do
    source "#{k8s}.erb"
    variables :kubernetes_cluster_tag => node['kubernetes']['kubernetes_cluster_tag']
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
