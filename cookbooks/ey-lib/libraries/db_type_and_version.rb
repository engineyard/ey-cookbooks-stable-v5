class Chef
  class Recipe
    # returns the db_type and specific version number
    # nil - no database, or unknown database
    def db_type_and_version
      case node.engineyard.environment['db_stack_name']
      when "postgres"
        ["postgres", "8.3"]
      when "postgres9"
        ["postgres", "9.0"]
      when /postgres(\d+)_(.*)/
        ["postgres", "#{$1}.#{$2}"]
      when "mysql"
        ["mysql", "5.0"]
      when /mysql(\d+)_(.*)/
        ["mysql", "#{$1}.#{$2}"]
      else
        nil
      end
    end

    def db_host_is_rds?
      node.engineyard.environment[:db_provider_name] == 'amazon_rds'
    end
  end

  class Resource
    def db_host_is_rds?
      node.engineyard.environment[:db_provider_name] == 'amazon_rds'
    end
  end
end
