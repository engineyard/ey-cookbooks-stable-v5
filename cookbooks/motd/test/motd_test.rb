module MotdRecipe
  class MotdTest < EY::Sommelier::TestCase
    scenario :alpha # during dev
    # scenario :beta # basic cluster on 32bit instances

    def test_app_master
      instance = instances(:app_master)

      motd = instance.ssh!("cat /etc/motd")
      puts motd
    end

  end
end
