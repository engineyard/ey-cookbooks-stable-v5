class Chef
  class Recipe
    # Is the current instance an app_master or a solo?
    # @return [Boolean] true if the instance fits the criteria, false otherwise
    def app_master_or_solo?(node)
      #['solo', 'app_master'].include?(node.dna.instance_role)
      instance = node.engineyard.instance

      instance.app_master? || instance.solo?
    end

    #def environment_metadata(node)
      #node.
        #engineyard.
        #environment.
        #component('environment_metadata') || {}
    #end

    ## Extract the crontab instance name from the node
    ## @return [String] an empty string when not set, otherwise the instance name
    #def crontab_instance_name(node)
      ##environment_metadata(node)['crontab_instance_name'].to_s
      #node.engineyard.environment.metadata(:crontab_instance_name, '')
    #end

    def util_instance?(node)
      node.engineyard.instance.util?
    end

    def instance_named?(node, name)
      node.engineyard.instance.name.to_s == name.to_s
    end

    # Is the instance a utility named as the provided name?
    # @return [Boolean] true if the instance is a util named "name", else false
    def utility_named?(node, name)
      return true if util_instance?(node) && instance_named?(node, name)

      false
    end

    # Is the current instance the crontab instance?
    # @return [Boolean] false by default, but true if any of the following
    #   conditions are are true:
    #
    #   * crontab instance name is set in the environment's metadata and matches
    #     the current instance
    #   * crontab instance name is not set and the current instance is an app
    #     master or a solo
    def crontab_instance?(node)
      crontab_instance_name = node.
        engineyard.
        environment.
        metadata(:crontab_instance_name, '')

      case crontab_instance_name
      when ''
        return true if app_master_or_solo?(node)
      else
        return true if utility_named?(node, crontab_instance_name)
      end

      false
    end
  end
end
