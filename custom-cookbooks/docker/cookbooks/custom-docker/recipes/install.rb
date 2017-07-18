docker_installation_tarball "default" do
  source "https://get.docker.com/builds/Linux/x86_64/docker-1.12.0.tgz"
  checksum "3dd07f65ea4a7b4c8829f311ab0213bca9ac551b5b24706f3e79a97e22097f8b"
  version "1.12.0"
end

directory "/data/docker/graph" do
  action :create
  recursive true
  owner "root"
  group "root"
  mode 0755
end

docker_service_manager_monit "default" do
  graph "/data/docker/graph"
  storage_driver "overlay"
end

