module EyBackupRecipe
  class PostgresCronTest < EY::Sommelier::TestCase
    scenario :delta

    def test_eybackup_for_postgres_crontab_entry
      instance = instances(:db_master)

      instance.ssh!("crontab -l | grep 'eybackup -e postgresql'")
    end

    def test_no_eybackup_crontab_entry_for_non_db_master
      instances.reject {|i| i.role.to_s == 'db_master' }.each do |instance|
        instance.ssh!("! crontab -l | grep 'eybackup -e postgresql'")
      end
    end
  end

  class MysqlCronTest < EY::Sommelier::TestCase
    scenario :gamma

    def test_eybackup_for_mysql_crontab_entry
      instance = instances(:db_master)

      instance.ssh!("crontab -l | grep 'eybackup'")
    end

    def test_no_eybackup_crontab_entry_for_non_db_master
      instances.reject {|i| i.role.to_s == 'db_master' }.each do |instance|
        instance.ssh!("! crontab -l | grep 'eybackup'")
      end
    end
  end
end
