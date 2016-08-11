module MongrelRecipes
  module RackStack
    class NginxVersionTest < EY::Sommelier::TestCase
      scenario :nu

      def test_nginx_version
        instance = instances(:app_master)

        instance.ssh!(%q{nginx -v 2>&1 | grep -q "1.0.15"})
      end
    end
  end
end
