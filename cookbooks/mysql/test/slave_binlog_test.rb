module MysqlRecipe
  class SlaveBinlogTest < EY::Sommelier::TestCase
    scenario :gamma

    def test_master_binlogs_deleted
      instance = instances(:db_slave)
      1.upto(10) do
        return if instance.ssh("! test -f /db/mysql/master-bin*").success?
        sleep 30
      end

      raise "Timeout"
    end
  end
end
