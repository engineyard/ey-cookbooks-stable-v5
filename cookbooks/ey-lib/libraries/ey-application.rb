class Chef
  module EY
    class Application
      def self.all(node, applications = nil)
        apps = []
        (applications || node.dna.applications).each do |name, app|
          apps << new(name, app, node)
        end
        apps
      end

      attr_reader :name, :database_name, :database_username, :database_password, :root, :path

      def initialize(name, app, node, root = '/data')
        @app  = app
        @name = name
        @node = node
        @database_name = ey_app['database_name'] || name
        @database_username = ey_app['database_username'] || node.engineyard.environment.ssh_username
        @database_password = ey_app['database_password'] || node.engineyard.environment.ssh_password
        @root = root
        @path = File.join(root, name)
      end

      def https?
        @app['vhosts'].any? {|vhost| vhost.key?('crt')}
      end

      def generate_skeleton(&block)
        default_paths.each do |dir|
          block.call(dir)
        end
      end

      def recipes
        return @recipes if @recipes

        @recipes = @app['recipes']
        # Fix for SD-4531: Remove application specific recipes for database and utility nodes.
        @recipes -= app_server_recipes unless @node.engineyard.instance.has_role?(:app)

        @recipes
      end

      def app_type
        @app['type'] == 'rails' ? 'rails' : 'rack'
      end

      def newrelic?
        @app['newrelic']
      end

      def default_paths
        %w( shared shared/bin shared/config shared/pids shared/system releases ).map do |dir|
          File.join(@path, dir)
        end
      end

      def join(path)
        File.join(@path, path)
      end

      def vhosts
        ey_app['vhosts'].map do |v|
          Vhost.new(v, self)
        end
      end

      def [](name)
        @app[name]
      end

      def ey_app
        @node.engineyard.environment['apps'].detect {|a| a['name'] == name}
      end

      def metadata(key=nil,default=nil)
        unless @component_metadata
          @component_metadata = ey_app['components'].
            detect {|c| c['key'] == 'app_metadata'}.
            dup.reject {|k| k == 'key'}
        end
        key.nil? ? @component_metadata.dup : @component_metadata.fetch(key.to_s,default)
      end

      def metadata?(key)
        # For legacy support
        metadata(key)
      end

      def method_missing(method, *args)
        if @app.respond_to?(method)
          @app.send(method, *args)
        elsif @app[method]
          @app[method]
        else
          super
        end
      end

      def app_server_recipes
        ['nginx', 'trinidad', 'thin', 'puma', 'passenger', 'passenger3', 'passenger4',
          'passenger::apache', 'passenger::nginx', 'mongrel',
          'unicorn', 'node::standard', 'node::tcp', 'passenger5']
      end

      class Vhost
        attr_reader :app
        def initialize(hash, app)
          @hash = hash
          @app = app
        end

        def [](name)
          @hash[name]
        end

        def https?
          !@hash['ssl_cert'].nil?
        end

        def respond_to?(method)
          @hash.key?(method.to_s) || super
        end

        def method_missing(method, *args)
          @hash.key?(method.to_s) ? @hash[method.to_s] : super
        end
      end
    end
  end
end
