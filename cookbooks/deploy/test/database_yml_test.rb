module DeployRecipe
  class DatabaseYmlTest < EY::Sommelier::TestCase
    scenario :alpha

    def test_database_yml_integrity
      instance = instances(:solo)

      database_yml = instance.ssh('cat /data/rails/shared/config/database.yml').stdout

      ['database', 'password', 'host', 'username'].each do |test_key|
        test_regex = /#{test_key}:\s+'.*'/
        assert_match test_regex, database_yml
      end
    end
  end
end
