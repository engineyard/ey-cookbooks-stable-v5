default['docker_custom'] = {
  :docker_instances => ["docker", "kubernetes_master", "kubernetes_node"]
}

default['docker_custom']['registries'] = %w(https://index.docker.io/v1/)

