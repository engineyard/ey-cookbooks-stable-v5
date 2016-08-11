module EYBinRecipe
  class EYMonitScriptsTest < EY::Sommelier::TestCase
    scenario :alpha

    def test_ey_monit_scripts_version
      instance = instances(:solo)
      instance.ssh!("eix -I sys-apps/ey-monit-scripts-0.19.23")
    end
  end
end
