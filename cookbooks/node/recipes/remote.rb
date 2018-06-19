node_version = node['nodejs']['version']
node_download_url = "https://nodejs.org/download/release/v#{node_version}/node-v#{node_version}-linux-x64.tar.gz"
node_tarball_filename = "node-v#{node_version}-linux-x64.tar.gz"

execute "downloading nodejs" do
  cwd "/opt/nodejs"
  command "wget #{node_download_url}"
  not_if { File.exist?("/opt/nodejs/#{node_tarball_filename}") }
end

execute "unarchive nodejs installer" do
  cwd "/opt/nodejs"
  command "tar zxf #{node_tarball_filename}"
  not_if { Dir.exist?("/opt/nodejs/node-v#{node_version}-linux-x64") }
end

link "/usr/bin/node" do
  to "/opt/nodejs/node-v#{node_version}-linux-x64/bin/node"
end

link "/usr/bin/npm" do
  to "/opt/nodejs/node-v#{node_version}-linux-x64/bin/npm"
end

link "/opt/nodejs/current" do
  to "/opt/nodejs/node-v#{node_version}-linux-x64"
end

