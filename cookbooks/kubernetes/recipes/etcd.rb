version = "2.3.7"
etcd_checksum = "ab102d271026a4060c9f85ecad11f454d82b1df7b8e676cc3da69f67eb078729"
etcd_src_filename = "etcd-v#{version}-linux-amd64.tar.gz"
etcd_src_filepath = "/tmp/#{etcd_src_filename}"
etcd_extract_path = "/tmp/etcd-#{version}"

Chef::Log.info "etcd src filepath: #{etcd_src_filepath}"
Chef::Log.info "etcd extract path: #{etcd_extract_path}"

remote_file etcd_src_filepath do
  source "https://github.com/coreos/etcd/releases/download/v#{version}/#{etcd_src_filename}"
  checksum etcd_checksum #sha256
  owner 'root'
  group 'root'
  mode '0755'
end

bash 'extract etcd' do
  cwd ::File.dirname(etcd_src_filepath)
  code <<-EOH
    mkdir -p #{etcd_extract_path}
    tar xzf #{etcd_src_filepath} -C #{etcd_extract_path}
  EOH
  not_if { ::File.exists?(etcd_extract_path) && ::File.exists?("#{etcd_extract_path}/etcd-v#{version}-linux-amd64/etcd") }
end

%w[etcd etcdctl].each do |etcd_file|
  execute "copy file to /usr/local/bin/#{etcd_file}" do
    command "cp #{etcd_extract_path}/etcd-v#{version}-linux-amd64/#{etcd_file} /usr/local/bin/#{etcd_file}"
    not_if { File.exist?("/usr/local/bin/#{etcd_file}") }
  end
end

execute "service-etcd-restart" do
  command "service etcd restart"
  action :nothing
end

begin
template "/etc/default/etcd" do
  source "etcd.erb"
  variables :host_ip => "localhost"
  notifies :run, resources(:execute => "service-etcd-restart"), :delayed
end

template "/etc/systemd/system/etcd.service" do
  source "etcd.service.erb"
  mode "0755"
  notifies :run, resources(:execute => "service-etcd-restart"), :delayed
end
end
