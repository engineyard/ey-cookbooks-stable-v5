module UnicornRecipe
  class NginxTest < EY::Sommelier::TestCase
    scenario :delta

    def test_nginx_version
      instance = instances(:app_master)

      instance.ssh!("nginx -v 2>&1 | grep -q 1.0.15")
    end
  end
end
