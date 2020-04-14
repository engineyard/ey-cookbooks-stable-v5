require 'base64'

module EnvVars
  module Helper

    def fetch_environment_variables(app_data)
      metadata = app_data['components'].find {|component| component['key'] == 'app_metadata'}
      return [] unless metadata && metadata['environment_variables']

      variables = metadata['environment_variables'].map do |var_hash|
        { :name => var_hash['name'], :value => ::Base64.strict_decode64(var_hash['value']) }
      end
    end

    # Escapes the value of variable to be correctly enclosed in double quotes. Enclosing characters
    # in double quotes (") preserves the literal value of all characters within the quotes, with the
    # exception of $, `, \, and, when history expansion is enabled, !.
    def escape_variable_value(value)
      value.gsub(/[`$"\\]/) { |x| "\\#{x}" }
    end

  end
end

Chef::Recipe.send(:include, EnvVars::Helper)
Chef::Resource.send(:include, EnvVars::Helper)
