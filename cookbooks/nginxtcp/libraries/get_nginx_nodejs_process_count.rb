class Chef
  class Recipe
    # The total number of nodejs processes is the number of CPU/virtual CPUs
    # on the assumption that nodejs can fully utilize a single process
    # and is not bound by any other constraints (memory, etc)
    # For Amazon AWS, see http://aws.amazon.com/ec2/instance-types/
    def get_nginx_nodejs_per_cpu_process_count
      vcpus = Engineyard::PoolSize.instance_resources(node['ec2']['instance_type']).vcpus
      vcpus > 8 ? 8 : vcpus # based on the implied rule in the old code that the count goes no higher than 8
    end
  end
end
