module CollectdRecipe
  class MiniHttpdTest < EY::Sommelier::TestCase
    scenario :alpha

    def test_mini_httpd_monitored
      instance = instances(:solo)
      instance.ssh!(%q{monit summary | grep "Process 'mini_httpd'" | grep 'running'})
    end
  end
end
