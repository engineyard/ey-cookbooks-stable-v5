module UnicornRecipe
  class StartTest < EY::Sommelier::TestCase
    scenario :delta
    destructive!

    def test_start_app
      instance = instances(:app_master)

      instance.ssh!("/engineyard/bin/app_rails stop")
      assert !instance.ssh("/engineyard/bin/app_rails status").success?

      instance.ssh!("/engineyard/bin/app_rails start")
      instance.ssh!("/engineyard/bin/app_rails status")
    end
  end

  class DeployTest < EY::Sommelier::TestCase
    scenario :delta
    destructive!

    def test_deploy_app
      instance = instances(:app_master)

      instance.ssh!("/engineyard/bin/app_rails deploy")
      instance.ssh!("/engineyard/bin/app_rails status")
    end
  end

  class ReloadTest < EY::Sommelier::TestCase
    scenario :delta
    destructive!

    def test_reload_app
      instance = instances(:app_master)

      instance.ssh!("/engineyard/bin/app_rails reload")
      instance.ssh!("/engineyard/bin/app_rails status")
    end
  end

  class PermissionsTest < EY::Sommelier::TestCase
    scenario :delta
    destructive!

    def test_permissions
      instance = instances(:app_master)

      instance.ssh!("chown root:root /data/rails/shared/log/*.log")
      instance.ssh!("/engineyard/bin/app_rails stop")
      instance.ssh!("/engineyard/bin/app_rails start")
    end
  end
end
