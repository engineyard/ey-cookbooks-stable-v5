class Chef
  class Recipe
    def get_fpm_count
      if ['solo'].include?(node.dna['instance_role'])
        allocated_memory = 1000
      else
        allocated_memory = 250
      end
      available_memory = (node['memory']['total'].to_i / 1000) - allocated_memory
      mem_max_workers = available_memory / 128
      mem_max_workers = mem_max_workers - (mem_max_workers * 0.1).to_i

      cpu_max_workers = (node['cpu']['total'].to_i * 3)

      return (cpu_max_workers < mem_max_workers) ? cpu_max_workers : mem_max_workers
    end
  end
end
