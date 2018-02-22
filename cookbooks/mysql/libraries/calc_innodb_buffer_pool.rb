class Chef
  class Recipe
    def calc_innodb_buffer_pool
      solo = ["solo"].include?( node['dna']['instance_role'] )
      total_memory = `cat /proc/meminfo`.scan(/^MemTotal:\s+(\d+)\skB$/).flatten.first.to_i * 1024
      total_memory_mb = (total_memory / 1024/1024)
      instance_role = open("http://169.254.169.254/latest/meta-data/instance-type").read
      if mem = Engineyard::PoolSize.instance_resources(instance_role).innodb_pool
        solo ? mem.first : mem.last
      else
        if solo
          total_memory_mb = 0.50 * total_memory_mb
        end

        if total_memory_mb <= 1100
          "#{(total_memory_mb * 0.70).to_i}M"
        elsif total_memory_mb > 1100 and total_memory_mb <= 2048
          "#{(total_memory_mb * 0.75).to_i}M"
        elsif total_memory_mb > 2048 and total_memory_mb <= 102400
          "#{(total_memory_mb * 0.80).to_i}M"
        elsif total_memory_mb > 102400 and total_memory_mb <= 204800
          "#{(total_memory_mb * 0.85).to_i}M"
        else
          "#{(total_memory_mb * 0.90).to_i}M"
        end
      end
    end
  end
end
