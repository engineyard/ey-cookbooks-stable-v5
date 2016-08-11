module UnicornRecipe
  class RailsTest < EY::Sommelier::TestCase
    scenario :delta

    def test_rails_use_proper_unicorn_scripts
      instance = instances(:app_master)
      instance.ssh!('pkill monit')
      instance.ssh!("ps aux | grep 'unicorn_rails master' | grep -v grep | awk '{print $2}' | xargs kill")
      sleep(40)
      instance.ssh!("ps aux | grep 'unicorn_rails master' | grep -v grep")
    end
  end
end
