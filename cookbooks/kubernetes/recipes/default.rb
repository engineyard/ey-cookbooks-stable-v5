execute "add apt key" do
  command "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -"
end
execute "add source" do
  command "echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' > /etc/apt/sources.list.d/kubernetes.list"
end

execute "apt-get update" do
end
execute "install packages" do
  command "apt-get install -y build-essential unzip python kubernetes-cni docker.io" 
  #"kubelet kubeadm kubectl kubernetes-cni"
end


if node['dna']['instance_role'] == "app_master"
  include_recipe "kubernetes::master"
end

if node['dna']['instance_role'] == "util" && node['dna']['name'] == "kubernetes_node"
  include_recipe "kubernetes::node"
end
