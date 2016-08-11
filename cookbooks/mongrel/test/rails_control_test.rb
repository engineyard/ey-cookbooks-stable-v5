module MongrelRecipes
  module RackStack
    module Helpers
      def pidfile(port)
        "/var/run/mongrel/rails/mongrel.#{port}.pid"
      end

      def restart_app(command)
        instance = instances(:app_master)

        old_pid = instance.ssh("cat #{pidfile(5000)}").stdout

        instance.ssh!("/engineyard/bin/app_rails #{command}")
        instance.ssh!("/engineyard/bin/app_rails status")

        new_pid = instance.ssh("cat #{pidfile(5000)}").stdout
        assert_not_equal(old_pid, new_pid)
      end
    end

    class StartTest < EY::Sommelier::TestCase
      include Helpers

      scenario :beta
      destructive!

      def test_start_app
        instance = instances(:app_master)

        instance.ssh!("/engineyard/bin/app_rails stop")
        assert !instance.ssh("/engineyard/bin/app_rails status").success?

        instance.ssh!("/engineyard/bin/app_rails start")
        instance.ssh!("/engineyard/bin/app_rails status")
      end
    end

    class RestartTest < EY::Sommelier::TestCase
      include Helpers

      scenario :beta
      destructive!

      def test_restart_app
        restart_app('restart')
      end
    end

    class DeployTest < EY::Sommelier::TestCase
      include Helpers

      scenario :beta
      destructive!

      def test_deploy_app
        # mongrels can't do anything different for deploy vs. restart;
        # they're synonyms.
        restart_app('deploy')
      end
    end

    class ListenTest < EY::Sommelier::TestCase
      include Helpers

      scenario :beta
      destructive!

      def test_app_listens
        instance = instances(:app_master)
        (5000..5007).each do |port|
          instance.ssh!("curl http://localhost:#{port}/")
        end
      end
    end

    class PidfileTest < EY::Sommelier::TestCase
      include Helpers

      scenario :beta
      destructive!

      def test_pidfile_present
        instance = instances(:app_master)
        (5000..5007).each do |port|
          instance.ssh!("test -f #{pidfile(port)}")
        end
      end
    end
  end
end
