class Chef
  module EY
    class Instance
      def initialize(hash,node)
        @hash = hash
        @node = node # Future proofing and consistancy
      end

      def id
        @hash['id']
      end

      def component?(name)
        @hash['components'].any? {|c| c['key'] == name.to_s}
      end

      def component(name)
        @hash['components'].detect {|c| c['key'] == name.to_s}
      end

      def roles
        case role
        when 'solo'
          %w[db_master app lb]
        when 'app','app_master'
          %w[app lb]
        when 'db_slave'
          %w[db_replica]
        else
          [role]
        end
      end

      def has_role?(*desired_roles)
        (roles.map(&:to_sym) & desired_roles.map(&:to_sym)).any?
      end

      # Support a more natural way of accessing hash members and components
      def respond_to?(method)
        # @hash.key? method is broken so check keys list
        ([method, method.to_s] - @hash.keys).length < 2 || component?(method.to_s) || super
      end

      def method_missing(method, *args)
        respond_to?(method) ? (@hash[method] || @hash[method.to_s] || component?(method.to_s) || super) : super
      end
    end
  end
end
