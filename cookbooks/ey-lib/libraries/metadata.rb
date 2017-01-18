class Chef
  class Recipe
    # Add's helpers for Metadata.  You can now use commands like
    #
    # :http_bind_port => metadata_env_get_with_default(:haproxy_http_port, "80"),
    #
    def metadata_account_get(name)
      data = node.engineyard.environment.components.select {|e| e['key'] == 'environment_metadata'} if node.engineyard.environment.component?('environment_metadata')
      data.first[name.to_s] if data
    end

    def metadata_account_get_with_default(name, default)
      metadata_account_get(name) || default
    end

    def metadata_env_get(name)
      environment = node.engineyard.environment['name']
      data = node.engineyard.environment.components.select {|e| e['key'] == 'environment_metadata'} if node.engineyard.environment.component?('environment_metadata')
      if data
        data.first[name.to_s] || data.first["#{name}[#{environment}]"]
      end
    end

    def metadata_env_get_with_default(name, default)
      metadata_env_get(name) || default
    end

    def metadata_app_get(appname, name)
      app = node.engineyard.apps.detect {|a| a.name == appname } and app.metadata?(name)
    end

    def metadata_app_get_with_default(appname, name, default)
      metadata_app_get(appname, name) || default
    end

    # App can be set for all slices with an app or it
    # can be set on app_deploy which only shows on that environment
    def metadata_any_app_get(name)
      app = node.engineyard.apps.detect {|a| a.metadata?(name) } and app.metadata?(name)
    end

    def metadata_any_app_get_with_default(name, default)
      metadata_any_app_get(name) || default
    end

    def metadata_any_get(name)
      # Starts at the app level but will also check env and account level
      metadata_any_app_get(name) || metadata_env_get(name) || metadata_account_get(name)
    end

    def metadata_any_get_with_default(name, default)
      metadata_any_get(name) || default
    end

    def metadata_dump
      Chef::Log.info("Metadata - Account")
      account_data = node.engineyard.environment.components.select {|e| e['key'] == 'environment_metadata'} if node.engineyard.environment.component?('environment_metadata')
      account_data.each { |data| p data}
      Chef::Log.info("Metadata - Apps")
      node.engineyard.apps.collect.each {|a| p "AppName: " + a.name ; p a.metadata }
      Chef::Log.info("Metadata - End")
    end
  end
end
