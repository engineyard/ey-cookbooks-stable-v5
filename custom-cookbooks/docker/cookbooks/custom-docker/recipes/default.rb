install_docker = node['dna']['instance_role'] == "util" && node['docker_custom']['docker_instances'].include?(node['dna']['name'])

if install_docker
  include_recipe "docker_custom::install"

  include_recipe 'docker_custom::registry'
end

