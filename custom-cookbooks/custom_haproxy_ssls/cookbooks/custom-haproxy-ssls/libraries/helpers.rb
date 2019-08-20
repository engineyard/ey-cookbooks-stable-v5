#require 'base64'
require 'openssl'

module CustomSSL
  module Helper

    def fetch_environment_variables(app_data)
      metadata = app_data['components'].find {|component| component['key'] == 'app_metadata'}
      return [] unless metadata && metadata['environment_variables']

      variables = metadata['environment_variables'].map do |var_hash|
        { :name => var_hash['name'], :value => ::Base64.strict_decode64(var_hash['value']) }
      end
    end


    def fetch_custom_ssl_pem(app_data,aev)
      custom_ssl_pem = ''
      env_vars = fetch_environment_variables(app_data)
      env_vars.each do |ev|
        if aev[:name].match(ev[:name])
          custom_ssl_pem = ev[:value]
        end
      end
      return custom_ssl_pem
    end

  end
end

Chef::Recipe.send(:include, CustomSSL::Helper)
Chef::Resource.send(:include, CustomSSL::Helper)
