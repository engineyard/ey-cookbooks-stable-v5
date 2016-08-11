class Chef
  class Node
    def instances
      self.engineyard.environment["instances"]
    end

    def private_ip_for(instance)
      require 'resolv'
      Resolv.getaddress(instance["private_hostname"])
    rescue Resolv::ResolvError
      nil
    end

    def cluster
      instances.map do |i|
        private_ip_for(i)
      end.compact
    end

    def app_master
      instances.select do |i|
        ["solo", "app_master"].include?(i["role"])
      end.map do |i|
        private_ip_for(i)
      end.compact
    end

    def app_slaves
      instances.select do |i|
        ["app"].include?(i["role"])
      end.map do |i|
        private_ip_for(i)
      end.compact
    end

    def util_servers
      instances.select do |i|
        ["util"].include?(i["role"])
      end.map do |i|
        private_ip_for(i)
      end.compact
    end

    def db_servers
      db_master + db_slaves
    end

    def db_master
      instances.select do |i|
        ["db_master"].include?(i["role"])
      end.map do |i|
        private_ip_for(i)
      end.compact
    end

    def db_slaves
      instances.select do |i|
        ["db_slave"].include?(i["role"])
      end.map do |i|
        private_ip_for(i)
      end.compact
    end
  end
end
