class Chef
  module EY

    class EngineYard

      class << self
        def build(node)
          @@singleton ||= self.new(node)
        end
      end

      def initialize(node)
        @node=node
      end

      # Core Node Objects
      def instance
        @instance ||= assemble_instance
      end

      def environment
        @environment ||= assemble_environment
      end

      def apps
        @apps ||= assemble_applications
      end

      def reset!
        @instance = nil
        @environment = nil
        @apps = nil
      end

      alias :applications :apps

      # Metadata Fetch
      def metadata(key,default=nil)
        apps.metadata(key, environment.metadata(key,default))
      end

      private

      def assemble_instance
        id = @node.dna['engineyard']['this']
        Chef::EY::Instance.new(@node.engineyard.environment['instances'].detect {|i| i['id'] == id}, @node)
      end

      def assemble_environment
        Chef::EY::Environment.new(@node)
      end

      def assemble_applications
        @apps = Chef::EY::Application.all(@node)

        # Add collection metadata method
        def @apps.metadata(key, default=nil)
          app = self.detect {|a| a.metadata?(key)}
          app ? app.metadata(key,default) : default
        end
        @apps
      end

    end
  end
end

class Chef
  class Node
    def engineyard
      @ey_node_obj ||= Chef::EY::EngineYard.build(self)
    end
  end
end
