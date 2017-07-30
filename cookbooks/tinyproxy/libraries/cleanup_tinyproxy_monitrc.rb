class Chef
  class Recipe
    def cleanup_tinyproxy_monitrc
      file '/etc/monit.d/tinyproxy.monitrc' do
        action :delete
        ignore_failure
      end
    end
  end
end
