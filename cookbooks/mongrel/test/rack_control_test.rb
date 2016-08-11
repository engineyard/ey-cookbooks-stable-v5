module MongrelRecipes
  module RackStack
    module Helpers
      def pidfile(port)
        "/var/run/mongrel/rack_app/mongrel.#{port}.pid"
      end

      def restart_app(command)
        instance = instances(:app_master)

        old_pid = instance.ssh("cat #{pidfile(5000)}").stdout

        instance.ssh!("/engineyard/bin/app_rack_app #{command}")
        instance.ssh!("/engineyard/bin/app_rack_app status")
        assert instance.ssh!("sleep 10 && ps aux | grep mongrel | grep #{template.framework_env}").success?

        new_pid = instance.ssh("cat #{pidfile(5000)}").stdout
        assert_not_equal(old_pid, new_pid)
      end
    end

    class StartTest < EY::Sommelier::TestCase
      include Helpers

      scenario :nu
      destructive!

      def test_start_app
        instance = instances(:app_master)

        instance.ssh!("/engineyard/bin/app_rack_app stop")
        assert !instance.ssh("/engineyard/bin/app_rack_app status").success?
        assert instance.ssh!("sleep 10 && ps aux | grep mongrel | grep #{template.framework_env}").success?
        instance.ssh!("/engineyard/bin/app_rack_app start")
        instance.ssh!("/engineyard/bin/app_rack_app status")
      end
    end

    class RestartTest < EY::Sommelier::TestCase
      include Helpers

      scenario :nu
      destructive!

      def test_restart_app(command='restart')
        restart_app('restart')
      end

    end

    class DeployTest < EY::Sommelier::TestCase
      include Helpers

      scenario :nu
      destructive!

      def test_deploy_app
        # mongrels can't do anything different for deploy vs. restart;
        # they're synonyms.
        restart_app('deploy')
      end

    end

    class ListenTest < EY::Sommelier::TestCase
      include Helpers

      scenario :nu
      destructive!

      def test_app_listens
        instance = instances(:app_master)
        (5000...5008).each do |port|
          instance.ssh!("curl http://localhost:#{port}/")
        end
      end

    end

    class PidfileTest < EY::Sommelier::TestCase
      include Helpers

      scenario :nu
      destructive!

      def test_pidfile_present
        instance = instances(:app_master)
        (5000...5008).each do |port|
          instance.ssh!("test -f #{pidfile(port)}")
        end
      end

    end
  end
end
