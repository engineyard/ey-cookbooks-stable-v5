module CollectdRecipe
  class EyAlertTest < EY::Sommelier::TestCase
    scenario :alpha

    def test_ey_alert
      instance = instances(:solo)
      instance.ssh!("test -x /engineyard/bin/ey-alert.rb")
      instance.ssh!("grep '^#!/usr/local/ey_resin/ruby/bin/ruby' /engineyard/bin/ey-alert.rb")
    end
  end
end
