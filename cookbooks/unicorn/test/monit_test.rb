module UnicornRecipe
  class MonitrcTest < EY::Sommelier::TestCase
    scenario :gamma

    def test_monit_entry_per_app
      instance = instances(:app_master)
      template.apps.each do |app|
        output = instance.ssh("monit status | grep 'unicorn_#{app.name}_worker' -A 3 | grep 'status'").stdout
        output.split("\n").each do |line|
          line.should =~ /(^\s*status\s+(running|PPID changed)$)|(^\s*monitoring status\s+monitored$)/
        end
      end
    end
  end

  class MonitStartTest < EY::Sommelier::TestCase
    scenario :gamma
    destructive!

    def test_monit_starts_same_environment
      instance = instances(:app_master)
      instance.ssh!("ps aux | awk '/[u]nicorn master/{print $2}' | xargs -r kill")

      1.upto(25) do
        return if instance.ssh("ps aux | grep 'unicorn master' | grep -v grep").success?
        sleep 10
      end

      raise "Monit Timeout"
    end
  end

  class MonitPermissionsTest < EY::Sommelier::TestCase
    scenario :gamma
    destructive!

    def test_monit_retains_permissions
      instance = instances(:app_master)
      instance.ssh!("ps aux | awk '/[u]nicorn master/{print $2}' | xargs -r kill")

      sleep 10

      1.upto(25) do
        if instance.ssh("ps aux | grep 'unicorn master' | grep -v grep").success?
          return instance.ssh!("ps aux | grep 'unicorn master' | grep -v grep | awk '{print $1}' | grep 'deploy'")
        end
        sleep 10
      end

      raise "Monit Timeout"
    end
  end

  class MonitKillTest < EY::Sommelier::TestCase
    scenario :gamma
    destructive!

    def test_monit_can_stop_unicorn_clusters
      instance = instances(:app_master)
      instance.ssh!("monit stop all -g unicorn_rack_app")

      1.upto(15) do
        return if instance.ssh("! ps aux | grep 'unicorn master' | grep -v grep").success?
        sleep 10
      end
    end
  end
end
