remote_file "/usr/local/bin/cfssl" do
  source "https://pkg.cfssl.org/R1.2/cfssl_linux-amd64"
  mode '0755'
end

remote_file "/usr/local/bin/cfssljson" do
  source "https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64"
  mode '0755'
end

directory "/etc/kubernetes/pki/cfssl" do
  owner "root"
  group "root"
  mode 0755
  action :create
  recursive true
end

template "/etc/kubernetes/pki/cfssl/ca-csr.json" do
  source "ca-csr.json.erb"
  #notifies :run, resources(), :delayed
end

execute "generate the CA certificate and key" do
  command "cfssl gencert -initca cfssl/ca-csr.json | cfssljson -bare ca"
  cwd "/etc/kubernetes/pki"
  not_if { File.exists?("/etc/kubernetes/pki/ca.pem") }
end

template "/etc/kubernetes/pki/cfssl/ca-config.json" do
  source "ca-config.json.erb"
end

template "/etc/kubernetes/pki/cfssl/kubernetes-csr.json" do
  source "kubernetes-csr.json.erb"
  variables({
    public_hostname: node['ec2']['public_hostname'], 
    public_ip: node['ec2']['public_ipv4'], 
    private_hostname: node['ec2']['local_hostname'], 
    private_ip: node['ec2']['local_ipv4'],
    kubernetes_service_ip: node['kubernetes']['kubernetes_service_ip']
  })
end

execute "generate the Kubernetes certificate and key" do
  command "cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=cfssl/ca-config.json -profile=kubernetes cfssl/kubernetes-csr.json | cfssljson -bare kubernetes"
  cwd "/etc/kubernetes/pki"
  #not_if { File.exists?("/etc/kubernetes/pki/kubernetes.pem") }
  action :nothing
  subscribes :run, "template[/etc/kubernetes/pki/cfssl/ca-config.json]", :immediately
  subscribes :run, "template[/etc/kubernetes/pki/cfssl/kubernetes-csr.json]", :immediately
  only_if { File.exists?("/etc/kubernetes/pki/cfssl/ca-config.json") && File.exists?("/etc/kubernetes/pki/cfssl/kubernetes-csr.json") }
end

execute "generate the kubectl certificate and key" do
  command "cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=cfssl/ca-config.json -profile=kubectl cfssl/kubernetes-csr.json | cfssljson -bare kubectl"
  cwd "/etc/kubernetes/pki"
  #not_if { File.exists?("/etc/kubernetes/pki/kubectl.pem") }
  action :nothing
  subscribes :run, "template[/etc/kubernetes/pki/cfssl/ca-config.json]", :immediately
  subscribes :run, "template[/etc/kubernetes/pki/cfssl/kubernetes-csr.json]", :immediately
  only_if { File.exists?("/etc/kubernetes/pki/cfssl/ca-config.json") && File.exists?("/etc/kubernetes/pki/cfssl/kubernetes-csr.json") }
end

file "/etc/kubernetes/pki/kubey.conf" do
  content(lazy do
    pem = File.read("/etc/kubernetes/pki/kubectl.pem")
    encoded_pem = Base64.strict_encode64(pem)
    key = File.read("/etc/kubernetes/pki/kubectl-key.pem")
    encoded_key = Base64.strict_encode64(key)
    ca_pem = File.read("/etc/kubernetes/pki/ca.pem")
    encoded_ca_pem = Base64.strict_encode64(ca_pem)

    etc = {'apiVersion' => 'v1', 'kind' => 'Config', 'preferences' => {}, 'current-context' => 'kubey'}
    users = {'users' => [{'name' => 'kubey', 'user' => {'client-certificate-data' => encoded_pem, 'client-key-data' => encoded_key}}]}
    contexts = {'contexts' => ['name' => 'kubey', 'context' => {'user' => 'kubey', 'cluster' => 'kubey'}]}
    clusters = {'clusters' => ['name' => 'kubey', 'cluster' => {'server' => "https://#{node['ec2']['public_hostname']}", 'certificate-authority-data' => encoded_ca_pem}]}
    kubeconfig_hash = etc.merge(users).merge(contexts).merge(clusters)
    kubeconfig_hash.to_yaml
  end)
end

