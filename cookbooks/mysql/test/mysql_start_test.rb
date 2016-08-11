module MysqlRecipe
  class MasterTest < EY::Sommelier::TestCase
    scenario :beta

    def test_mysql_start_logs
      instance = instances(:db_master)
      instance.ssh!("test -f /root/chef-mysql.log")
    end
  end
end
