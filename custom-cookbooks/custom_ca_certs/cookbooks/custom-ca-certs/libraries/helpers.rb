require 'base64'
require 'openssl'

module CustomCACert
  module Helper
    def encrypt(value, secret)
      MessageCipher.new(secret).encrypt(value)
    end

    def decrypt(value, secret)
      MessageCipher.new(secret).decrypt(value)
    end

    def fetch_environment_variables(app_data)
      metadata = app_data['components'].find {|component| component['key'] == 'app_metadata'}
      return [] unless metadata && metadata['environment_variables']

      variables = metadata['environment_variables'].map do |var_hash|
        { :name => var_hash['name'], :value => ::Base64.strict_decode64(var_hash['value']) }
      end
    end


    def fetch_custom_ca_pem(app_data,aev)
      custom_ca_pem = ''
      env_vars = fetch_environment_variables(app_data)
      env_vars.each do |ev|
        if aev[:name].match(ev[:name])
          custom_ca_pem = ev[:value]
        end
      end
      return custom_ca_pem
    end

  end
end

Chef::Recipe.send(:include, CustomCACert::Helper)
Chef::Resource.send(:include, CustomCACert::Helper)
