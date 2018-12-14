require 'base64'
require 'openssl'

module SetHaproxy
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

    def tls_12_only(app_data)
      env_vars = fetch_environment_variables(app_data)
      env_vars.each do |ev|
        if /^EY_TLS_12/.match(ev[:name]) && /TRUE/i.match(ev[:value])
          return true
        end
      end
      return false
    end

    def http_2_enabled(app_data)
      env_vars = fetch_environment_variables(app_data)
      env_vars.each do |ev|
        if /^EY_HTTP2/.match(ev[:name]) && /TRUE/i.match(ev[:value])
         return true
       end
      end
      return false
    end
  end
end

Chef::Recipe.send(:include, SetHaproxy::Helper)
Chef::Resource.send(:include, SetHaproxy::Helper)
