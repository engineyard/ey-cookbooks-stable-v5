module EyMonitorRecipe
  class InittabTest < EY::Sommelier::TestCase
    scenario :beta

    def test_eymonitor_inittab_entries
      instance = instances(:app_master)
      instance.ssh!("pkill -f stonith-cron")
      instance.ssh!("ps aux | grep 'stonith-cron' | grep -v grep")
    end

    def test_redis_init_instance
       if node.engineyard.environment['db_stack_name'] == "no_db"
         #no-op
       else
          instance = instances(:db_master)
          instance.ssh!("ps aux | grep 'redis-server' | grep '/etc/engineyard/ey-stonith.redis.conf'")
          instance.ssh!("lsof -i tcp:6380 | grep 'redis'")
       end
    end

    def test_logrotate_entry
      instance = instances(:app_master)
      instance.ssh!("logrotate -d /etc/logrotate.d/ey-monitor")
    end
  end
end
