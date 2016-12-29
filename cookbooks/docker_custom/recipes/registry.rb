
registries = node['docker_custom']['registries']
credential_file = '/home/deploy/.docker/config.json'

ruby_block 'load docker registry credentials' do
  block do
    include CredentialTools

    registries.each do |endpoint|
      credentials = read_credentials

      registry = resources("docker_registry[#{endpoint}]")
      unless credentials[registry.serveraddress]
        raise "Cannot find credentials for registry #{registry.serveraddress}"
      end

      update_registry(registry)
    end
  end
  only_if { File.exists? credential_file }
end

registries.each do |endpoint|
  docker_registry endpoint do
    only_if { File.exists? credential_file }
  end
end
