#
# Get Pool Size
# -------------
#
# Expected pool size based on default settings
#
#    | Type            |     Memory |       Swap |   VCPUs |   Old Pool |   New Pool |
#    ---------------------------------------------------------------------------------
#    | m1.small        |    1700 MB |     895 MB |       1 |          3 |          3 |
#    | m1.medium       |    3840 MB |    1343 MB |       2 |          7 |          4 |
#    | m1.large        |    7680 MB |   30725 MB |       4 |          6 |          8 |
#    | m1.xlarge       |   15360 MB |   30725 MB |       8 |         12 |         16 |
#    | c1.medium       |    1740 MB |    1343 MB |       5 |          6 |          6 |
#    | c1.xlarge       |    7168 MB |   30725 MB |      20 |         24 |         40 |
#    | m2.xlarge       |   17500 MB |       0 MB |     6.5 |          8 |         13 |
#    | m2.2xlarge      |   35000 MB |       0 MB |      13 |          8 |         26 |
#    | m2.4xlarge      |   70000 MB |   30725 MB |      26 |         24 |         52 |
#    | hi1.4xlarge     |   62000 MB |   30725 MB |      35 |         70 |         70 |
#
# Note: m1.medium will return 7 (not 4) if no metadata is set, as a way to prevent
# too much of a surprise.
#
# https://gist.github.com/d236dd5b24738ed32b21
#

class Chef
  class Recipe
    module PoolSize
      class Settings
        # default settings
        DEFAULTS = {
          :reserved_memory => 1500, # MB
          :reserved_memory_solo => 2000, # MB
          :worker_memory_size => 250, # MB
          :workers_per_vcpu => 2,
          :min_pool_size => 3,
          :max_pool_size => 100,
          :db_vcpu_max => 0,
          :db_workers_per_vcpu => 0.5,
          :swap_usage_percent => 25
        }

        # setting keys
        KEYS = %w[
          reserved_memory
          reserved_memory_solo
          db_workers_per_vcpu
          db_vcpu_max
          worker_memory_size
          workers_per_vcpu
          swap_usage_percent
          min_pool_size
          max_pool_size
        ].map{|k| k.to_sym}

        # attributes
        attr_accessor :recipe

        # new
        def initialize(recipe)
          self.recipe = recipe
        end

        # pool size settings
        def settings
          @settings ||= begin
            settings = metadata_settings
            settings[:overridden] = !settings.empty?
            set_defaults(settings)
          end
        end

        def defaults?
          !settings[:overridden]
        end

        def [](key)
          self.settings[key.to_sym]
        end

        protected

        def metadata_settings
          KEYS.inject({}) do |memo, key|
            metadata = self.recipe.metadata_any_get(key)
            metadata ? memo.merge(key => metadata) : memo
          end
        end

        def set_defaults(hash)
          KEYS.each do |key|
            hash[key] = case key
      #      when :reserved_memory
      #        (self.recipe.node.solo? ?
      #          (hash[:reserved_memory_solo] || DEFAULTS[:reserved_memory_solo]) :
      #          (hash[:reserved_memory] || DEFAULTS[:reserved_memory])
      #        ).to_i
            when :workers_per_vcpu, :db_workers_per_vcpu
              (hash[key] || DEFAULTS[key]).to_f
            else
              (hash[key] || DEFAULTS[key]).to_i
            end
      #    end

           hash
         end
       end

      class Calculator
        # ecus
        ECUS = {
          "c1.medium"   => 5,
          "c1.xlarge"   => 20,
          "c3.2xlarge"  => 28,
          "c3.4xlarge"  => 55,
          "c3.8xlarge"  => 108,
          "c3.large"    => 7,
          "c3.xlarge"   => 14,
          "hi1.4xlarge" => 35,
          "m1.large"    => 4,
          "m1.medium"   => 2,
          "m1.small"    => 1,
          "m1.xlarge"   => 8,
          "m2.2xlarge"  => 13,
          "m2.4xlarge"  => 26,
          "m2.xlarge"   => 6.5
        }

        # attributes
        attr_accessor :recipe

        # new
        def initialize(recipe)
          self.recipe = recipe
        end

        def calculate(instance_size)
          # check for custom pool size
          custom_pool_size = self.recipe.metadata_any_get(:pool_size).to_i
          return custom_pool_size if custom_pool_size > 0

          # calculate maximums
          max_by_memory = ((available_memory - settings[:reserved_memory]) / settings[:worker_memory_size]).floor
          max_by_vcpu = (vcpu_count(instance_size) * settings[:workers_per_vcpu]).floor

          # reserve some of the worker resources for db activities on solos, if enabled
          max_by_vcpu -= ([vcpu_count(instance_size),settings[:db_vcpu_max]].min * settings[:db_workers_per_vcpu]).floor if self.recipe.node.solo?

          # overwrite certain instance types
          return 6 if instance_size[/c1.medium/] && settings.defaults?
          return 7 if instance_size[/m1.medium/] && settings.defaults?

          # find suitable pool size
          [[max_by_memory, max_by_vcpu, settings[:max_pool_size]].min, settings[:min_pool_size]].max
        end

        protected

        def settings
          @settings ||= Settings.new(self.recipe)
        end

        # this is actually asking for ECU count
        def vcpu_count(instance_size)
          ECUS[instance_size]
        end

        def available_memory
          meminfo = File.read('/proc/meminfo')
          memory = meminfo[/^MemTotal:\s+(\d+)/, 1].to_i / 1024
          swap = meminfo[/^SwapTotal:\s+(\d+)/, 1].to_i / 1024
          memory + (swap * settings[:swap_usage_percent] / 100).floor
        end
      end
    end

    def get_pool_size
      @pool_size ||= begin
        pool_size = PoolSize::Calculator.new(self).calculate(node.ec2_instance_size)
        Chef::Log.info "Worker pool size: #{pool_size}"
        pool_size
      end
    end
  end
end
end
