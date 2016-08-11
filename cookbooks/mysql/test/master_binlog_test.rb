module MysqlRecipe
  class MasterBinlogTest < EY::Sommelier::TestCase
    scenario :beta
    destructive!

    def test_cron_entry
      instance = instances(:db_master)

      instance.ssh!("crontab -l | grep -q binary_log_purge")
    end

    def test_purge_binlogs
      instance = instances(:db_master)

      instance.ssh!("/usr/local/ey_resin/bin/binary_log_purge -q")
    end
  end
end
