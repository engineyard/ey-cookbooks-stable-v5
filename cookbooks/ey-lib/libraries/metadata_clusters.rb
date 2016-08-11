class Chef
  class Recipe
    def clusters(type)
      if node.engineyard.environment['components'].detect{|n| n["key"] == "metadata"}
        node.engineyard.environment['components'].detect{|n| n["key"] == "metadata"}['clusters'].select{|c| c["type"] == type}
      end
    end

    def my_cluster(type, provisioned_id)
      clusters(type).detect{|clusters| clusters["nodes"].any?{|n| n["provisioned_id"] == provisioned_id} }
    end

    def get_node_info(type, provisioned_id, key)
      mycluster = my_cluster(type, provisioned_id)
      if mycluster
        thisnode = mycluster["nodes"].detect{|n| n["provisioned_id"] == provisioned_id}
        thisnode.dna[key]
      end
    end

    def clusters_provisioned_nodes_hostnames(type)
      require 'resolv'
      clusternodes = clusters(type).map {|c| c['nodes'].map{|hash| hash['provisioned_id']}}.flatten
      clusternodes.map do |c|
        private_hostname = get_node_hostname(c)
        begin
          Resolv.getaddress(private_hostname) # resolvable
          private_hostname
        rescue Resolv::ResolvError
          nil
        end
      end.compact
    end

    def get_node_hostname(provisioned_id)
      node.engineyard.environment['instances'].map{|x| x["private_hostname"] if x["id"] == provisioned_id}.compact.first
    end
    #end classes
  end
end
