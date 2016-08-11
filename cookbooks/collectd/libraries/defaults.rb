class Chef
  class Node
    def default_collectd(size)
      Collectd.defaults(size)
    end

    class Collectd < Struct.new(:size)
      def self.defaults(size)
        new(size).defaults
      end

      def graph_path
        '/var/www/localhost/htdocs/graphs'
      end

      def graph_version
        3
      end

      def defaults
        { :graph => {:path => graph_path,
                     :version_file => "#{graph_path}/version",
                     :graphs_tarball_name => "graphs_v#{graph_version}.tgz",
                     :version => graph_version },
          :version => '5.1.0-r3',
          :load => load_defaults }
      end

      def load_defaults
        { :warning => vcpus * 4,
          :failure => vcpus * 10 }
      end

      def vcpus
        Engineyard::PoolSize.instance_resources(size).vcpus || raise("Unknown instance size: #{size}")
      end
    end
  end
end
