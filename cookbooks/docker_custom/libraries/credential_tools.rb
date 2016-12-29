module CredentialTools
    def read_credentials(credential_file = '/home/deploy/.docker/config.json')
      require 'json'
      JSON.parse(File.read credential_file)['auths']
    end

    def update_registry(resource)
      require 'base64'
      base64 = Base64.decode64 credentials[resource.serveraddress]['auth']
      username, password = base64.split ':'

      resource.email credentials[resource.serveraddress]['auth']['email']
      resource.username  username
      resource.password password
      resource
    end
end
