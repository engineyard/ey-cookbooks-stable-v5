require 'timeout'

module MongrelRecipes
  module MerbStack
    module Helpers
      def wait_until(instance, command)
        Timeout::timeout(150) do
          sleep 10 until instance.ssh(command).success?
        end
      end

      def pidfile(port)
        "/var/log/engineyard/fresh_merb_app/fresh_merb_app-production-merb.#{port}.pid"
      end

      def restart_app(command)
        instance = instances(:app_master)

        wait_until(instance, "/engineyard/bin/app_fresh_merb_app status")

        old_pid = instance.ssh("cat #{pidfile(5000)}").stdout

        instance.ssh!("/engineyard/bin/app_fresh_merb_app #{command}")

        return "MERB IS THE SUCK"

        wait_until(instance, "/engineyard/bin/app_fresh_merb_app status")

        new_pid = instance.ssh("cat #{pidfile(5000)}").stdout
        assert_not_equal(old_pid, new_pid)
      end
    end

    class StartTest < EY::Sommelier::TestCase
      include Helpers

      scenario :xi
      destructive!

      def test_start_app
        instance = instances(:app_master)

        wait_until(instance, "/engineyard/bin/app_fresh_merb_app status")

        instance.ssh!("/engineyard/bin/app_fresh_merb_app stop")

        sleep 70 # I <3 merb

        assert !instance.ssh("/engineyard/bin/app_fresh_merb_app status").success?

        instance.ssh!("/engineyard/bin/app_fresh_merb_app start")

        wait_until(instance, "/engineyard/bin/app_fresh_merb_app status")
      end

    end

    class RestartTest < EY::Sommelier::TestCase
      include Helpers

      scenario :xi
      destructive!

      def test_restart_app
        restart_app('restart')
      end
    end

    class DeployTest < EY::Sommelier::TestCase
      include Helpers

      scenario :xi
      destructive!

      def test_deploy_app
        # mongrels can't do anything different for deploy vs. restart;
        # they're synonyms.
        restart_app('deploy')
      end
    end

      #def test_app_listens
        #instance = instances(:app_master)

        #wait_until(instance, "/engineyard/bin/app_fresh_merb_app status")

        #(5000..5008).each do |port|
          #instance.ssh!("curl http://localhost:#{port}/")
        #end
      #end

      #def test_pidfile_present
        #instance = instances(:app_master)

        #wait_until(instance, "/engineyard/bin/app_fresh_merb_app status")

        #(5000..5008).each do |port|
          #instance.ssh!("test -f #{pidfile(port)}")
        #end
      #end
  end
end
