module MysqlRecipe
  class ClientTest < EY::Sommelier::TestCase
    scenario :beta

    def test_list_backups
      instance = instances(:app_master)
      instance.ssh!("eybackup -l rails_production")
    end
  end
end
