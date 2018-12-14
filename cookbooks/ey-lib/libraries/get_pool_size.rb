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

class Engineyard
  module PoolSize
    class Settings
      # default settings
      DEFAULTS = {
        :reserved_memory => 1500, # MB
        :reserved_memory_solo => 2000, # MB
        :worker_memory_size => 250, # MB
        :workers_per_ecu => 2,
        :min_pool_size => 3,
        :max_pool_size => 100,
        :db_vcpu_max => 0,
        :db_workers_per_ecu => 0.5,
        :swap_usage_percent => 25
      }

      # setting keys
      KEYS = %w[
        reserved_memory
        reserved_memory_solo
        db_workers_per_ecu
        db_vcpu_max
        worker_memory_size
        workers_per_ecu
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
          when :reserved_memory
            (self.recipe.node.engineyard.instance.role == 'solo' ?
              (hash[:reserved_memory_solo] || DEFAULTS[:reserved_memory_solo]) :
              (hash[:reserved_memory] || DEFAULTS[:reserved_memory])
            ).to_i
          when :workers_per_ecu, :db_workers_per_ecu
            (hash[key] || DEFAULTS[key]).to_f
          else
            (hash[key] || DEFAULTS[key]).to_i
          end
        end

        hash
      end
    end

    class Calculator

      InstanceResource = Struct.new(:vcpus, :defined_ecus, :innodb_pool)
      class InstanceResource
        ECU_TO_VCPU_RATIO = 3.25

        # Amazon has a general conversion ration of 3.25 ECU per VCPU across all but the
        # earliest instance types (as of September 2014). However, their published ECU 
        # equivalencies sometimes vary from that. Where the ratio holds true, no specific 
        # ECU count needs to be defined, and the resource object will simply calculate 
        # the value from the VCPU count using the defined ratio.
        # VCPU and ECU counts were pulled from:
        #   http://aws.amazon.com/ec2/previous-generation/  -- OLD INSTANCE TYPES
        #   http://aws.amazon.com/ec2/pricing/              -- MODERN INSTANCES

        def ecus
          self.defined_ecus || self.vcpus * ECU_TO_VCPU_RATIO
        end
      end

      # If a specific set of values is not defined for the innodb_pool, the
      # recipe to calculate innodb pool size will determine that value algorithmically.
      # If specific values are set, they override the algorithm.

      Resources = Hash.new do |h,k|
        # parse cpuinfo and count the number of cores that it reports; use that as a default if asked for an unknown instance size.
        cores = File.read('/proc/cpuinfo').scan(/processor\s*:.*?cpu\s+cores\s*:\s*(\d+)/m).inject(0) {|a,x| a += x.first.to_i}
        h[k] = InstanceResource.new( cores, nil, nil )
      end

      Resources.merge!( {
        "m1.small"     => InstanceResource.new( 1,   1,   %w[512M   1275M]  ),
        "m1.medium"    => InstanceResource.new( 1,   2,   %w[1440M  2880M]  ),
        "m1.large"     => InstanceResource.new( 2,   4,   %w[3072M  6144M]  ),
        "m1.xlarge"    => InstanceResource.new( 4,   8,   %w[6144M  12288M] ),
        "c1.medium"    => InstanceResource.new( 2,   5,   %w[512M   1275M]  ),
        "c1.xlarge"    => InstanceResource.new( 8,   20,  %w[2878M  5756M]  ),
        "hi1.4xlarge"  => InstanceResource.new( 16,  35,  %w[24780M 49561M] ),
        "m2.xlarge"    => InstanceResource.new( 2,   nil, %w[7004M  14008M] ),
        "m2.2xlarge"   => InstanceResource.new( 4,   nil, %w[14008M 28016M] ),
        "m2.4xlarge"   => InstanceResource.new( 8,   nil, %w[28016M 56033M] ),
        "c3.large"     => InstanceResource.new( 2,   7,   nil               ),
        "c3.xlarge"    => InstanceResource.new( 4,   14,  nil               ),
        "c3.2xlarge"   => InstanceResource.new( 8,   28,  nil               ),
        "c3.4xlarge"   => InstanceResource.new( 16,  55,  nil               ),
        "c3.8xlarge"   => InstanceResource.new( 32,  108, nil               ),
        "m3.medium"    => InstanceResource.new( 1,   3,   nil               ),
        "m3.large"     => InstanceResource.new( 2,   nil, nil               ),
        "m3.xlarge"    => InstanceResource.new( 4,   nil, nil               ),
        "m3.2xlarge"   => InstanceResource.new( 8,   nil, nil               ),
        "t2.micro"     => InstanceResource.new( 1,   nil, nil               ),
        "t2.small"     => InstanceResource.new( 1,   nil, nil               ),
        "t2.medium"    => InstanceResource.new( 2,   nil, nil               ),
        "t2.large"     => InstanceResource.new( 2,   nil, nil               ),
        "r3.large"     => InstanceResource.new( 2,   nil, nil               ),
        "r3.xlarge"    => InstanceResource.new( 4,   nil, nil               ),
        "r3.2xlarge"   => InstanceResource.new( 8,   nil, nil               ),
        "r3.4xlarge"   => InstanceResource.new( 16,  nil, nil               ),
        "r3.8xlarge"   => InstanceResource.new( 32,  nil, nil               ),
        "c4.large"     => InstanceResource.new( 2,   nil, nil               ),
        "c4.xlarge"    => InstanceResource.new( 4,   nil, nil               ),
        "c4.2xlarge"   => InstanceResource.new( 8,   nil, nil               ),
        "c4.4xlarge"   => InstanceResource.new( 16,  nil, nil               ),
        "c4.8xlarge"   => InstanceResource.new( 36,  nil, nil               ),
        "m4.large"     => InstanceResource.new( 2,   nil, nil               ),
        "m4.xlarge"    => InstanceResource.new( 4,   nil, nil               ),
        "m4.2xlarge"   => InstanceResource.new( 8,   nil, nil               ),
        "m4.4xlarge"   => InstanceResource.new( 16,  nil, nil               ),
        "m4.10xlarge"  => InstanceResource.new( 40,  nil, nil               ),
        #Need to revisit and set all values for all instances, as ecu per vcpu is not the same on c,m and r instances
	#Not pushing as yet as will result in worker count change on existing instances and so needs KB article and announcment
        "t3.micro"     => InstanceResource.new( 2,   4,   nil               ),
        "t3.small"     => InstanceResource.new( 2,   8,   nil               ),
        "t3.medium"    => InstanceResource.new( 2,   8,   nil               ),
        "t3.large"     => InstanceResource.new( 2,   8,   nil               ),
        "t3.xlarge"    => InstanceResource.new( 4,   16,  nil               ),
        "t3.2xlarge"   => InstanceResource.new( 4,   31,  nil               ),
        "m5.large"     => InstanceResource.new( 2,   8,   nil               ),
        "m5.xlarge"    => InstanceResource.new( 4,   16,  nil               ),
        "m5.2xlarge"   => InstanceResource.new( 8,   31,  nil               ),
        "m5.4xlarge"   => InstanceResource.new( 16,  60,  nil               ),
        "m5.12xlarge"  => InstanceResource.new( 48,  173, nil               ),
        "m5.24xlarge"  => InstanceResource.new( 96,  345, nil               ),
        "m5a.large"    => InstanceResource.new( 2,   8,   nil               ),
        "m5a.xlarge"   => InstanceResource.new( 4,   16,  nil               ),
        "m5a.2xlarge"  => InstanceResource.new( 8,   31,  nil               ),
        "m5a.4xlarge"  => InstanceResource.new( 16,  60,  nil               ),
        "m5a.12xlarge" => InstanceResource.new( 48,  173, nil               ),
        "m5a.24xlarge" => InstanceResource.new( 96,  345, nil               ),
        "m5d.large"    => InstanceResource.new( 2,   8,   nil               ),
        "m5d.xlarge"   => InstanceResource.new( 4,   16,  nil               ),
        "m5d.2xlarge"  => InstanceResource.new( 8,   31,  nil               ),
        "m5d.4xlarge"  => InstanceResource.new( 16,  60,  nil               ),
        "m5d.12xlarge" => InstanceResource.new( 48,  173, nil               ),
        "m5d.24xlarge" => InstanceResource.new( 96,  345, nil               ),
        "c5.large"     => InstanceResource.new( 2,   9,   nil               ),
        "c5.xlarge"    => InstanceResource.new( 4,   17,  nil               ),
        "c5.2xlarge"   => InstanceResource.new( 8,   34,  nil               ),
        "c5.4xlarge"   => InstanceResource.new( 16,  68,  nil               ),
        "c5.9xlarge"   => InstanceResource.new( 36,  141, nil               ),
        "c5.18xlarge"  => InstanceResource.new( 72,  281, nil               ),
        "c5d.large"    => InstanceResource.new( 2,   9,   nil               ),
        "c5d.xlarge"   => InstanceResource.new( 4,   17,  nil               ),
        "c5d.2xlarge"  => InstanceResource.new( 8,   34,  nil               ),
        "c5d.4xlarge"  => InstanceResource.new( 16,  68,  nil               ),
        "c5d.9xlarge"  => InstanceResource.new( 36,  141, nil               ),
        "c5d.18xlarge" => InstanceResource.new( 72,  281, nil               ),
        "r5.large"     => InstanceResource.new( 2,   10,  nil               ),
        "r5.xlarge"    => InstanceResource.new( 4,   19,  nil               ),
        "r5.2xlarge"   => InstanceResource.new( 8,   38,  nil               ),
        "r5.4xlarge"   => InstanceResource.new( 16,  71,  nil               ),
        "r5.12xlarge"  => InstanceResource.new( 48,  173, nil               ),
        "r5.24xlarge"  => InstanceResource.new( 96,  347, nil               ),
        "r5a.large"    => InstanceResource.new( 2,   10,  nil               ),
        "r5a.xlarge"   => InstanceResource.new( 4,   19,  nil               ),
        "r5a.2xlarge"  => InstanceResource.new( 8,   38,  nil               ),
        "r5a.4xlarge"  => InstanceResource.new( 16,  71,  nil               ),
        "r5a.12xlarge" => InstanceResource.new( 48,  173, nil               ),
        "r5a.24xlarge" => InstanceResource.new( 96,  347, nil               ),
        "r5d.large"    => InstanceResource.new( 2,   10,  nil               ),
        "r5d.xlarge"   => InstanceResource.new( 4,   19,  nil               ),
        "r5d.2xlarge"  => InstanceResource.new( 8,   38,  nil               ),
        "r5d.4xlarge"  => InstanceResource.new( 16,  71,  nil               ),
        "r5d.12xlarge" => InstanceResource.new( 48,  173, nil               ),
        "r5d.24xlarge" => InstanceResource.new( 96,  347, nil               ),
        "i3.large"     => InstanceResource.new( 2,   7,   nil               ),
        "i3.xlarge"    => InstanceResource.new( 4,   13,  nil               ),
        "i3.2xlarge"   => InstanceResource.new( 8,   27,  nil               ),
        "i3.4xlarge"   => InstanceResource.new( 16,  53,  nil               ),
        "i3.8xlarge"   => InstanceResource.new( 32,  99,  nil               ),
        "i3.16xlarge"  => InstanceResource.new( 64,  200, nil               )
      } )

      # attributes
      attr_accessor :recipe

      # new
      def initialize(recipe)
        self.recipe = recipe
      end

      def calculate(instance_size)
        if custom_pool_size > 0
          custom_pool_size
        elsif instance_size[/c1.medium/] && settings.defaults?
          6
        elsif instance_size[/m1.medium/] && settings.defaults?
          7
        else
          calculate_pool_size(instance_size)
        end
      end

      protected

      def settings
        @settings ||= Settings.new(self.recipe)
      end

      def ecu_count(instance_size)
        Resources[instance_size].ecus
      end

      def custom_pool_size
        self.recipe.metadata_any_get(:pool_size).to_i
      end

      def max_by_memory
        ( ( available_memory - settings[:reserved_memory] ) / settings[:worker_memory_size] ).floor
      end

      def max_by_ecu(instance_size)
        worker_count = ( ecu_count(instance_size) * settings[:workers_per_ecu] ).floor
        if self.recipe.node.engineyard.instance.role == 'solo'
          worker_count - ( [ ecu_count(instance_size), settings[:db_vcpu_max] ].min * settings[:db_workers_per_ecu] ).floor
        else
          worker_count
        end
      end

      def calculate_pool_size(instance_size)
        apps_count  = self.recipe.metadata_get_apps_count
        smallest_of_maximums = [ max_by_memory, max_by_ecu(instance_size), settings[:max_pool_size] ].min
        ([ smallest_of_maximums, settings[:min_pool_size] ].max / apps_count).floor
      end

      def available_memory
        meminfo = File.read('/proc/meminfo')
        memory = meminfo[/^MemTotal:\s+(\d+)/, 1].to_i / 1024
        swap = meminfo[/^SwapTotal:\s+(\d+)/, 1].to_i / 1024
        memory + (swap * settings[:swap_usage_percent] / 100).floor
      end
    end

    def self.instance_resources(instance_size)
      Engineyard::PoolSize::Calculator::Resources[instance_size]
    end

  end
end

class Chef
  class Recipe

    def get_pool_size
      @pool_size ||= begin
        pool_size = Engineyard::PoolSize::Calculator.new(self).calculate(node.ec2_instance_size)
        Chef::Log.info "Worker pool size: #{pool_size}"
        pool_size
      end
    end

  end
end
