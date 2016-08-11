module MysqlRecipe
  class SlaveYmlTest < EY::Sommelier::TestCase
    scenario :gamma

    def test_mysql_yml_present
      instance = instances(:db_slave)

      instance.ssh!('test -f /etc/.mysql.backups.yml')
    end
  end
end
