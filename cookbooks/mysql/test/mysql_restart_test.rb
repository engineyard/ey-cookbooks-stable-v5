module MysqlRecipe
  class RestartTest < EY::Sommelier::TestCase
    scenario :gamma
    destructive!

    def test_prevent_unnecessary_restarts
      instance = instances(:db_master)
      old_pid = instance.ssh('pgrep mysqld').stdout.chomp

      redeploy(:db_master)

      new_pid = instance.ssh('pgrep mysqld').stdout.chomp
      new_pid.should == old_pid
    end
  end
end
