module NewRelicRecipe
  class ConfigTest < EY::Sommelier::TestCase
    scenario :epsilon

    def test_newrelic_yml_is_linked
      instance = instances(:solo)
      instance.ssh!('test -d /data/newrelic_app/current/config')
      instance.ssh!('test -L /data/newrelic_app/current/config/newrelic.yml')
      instance.ssh!('cat /data/newrelic_app/current/config/newrelic.yml')
    end

    def test_unused_newrelic_yml
      instance = instances(:solo)
      instance.ssh!('test -f /data/unused_newrelic_app/shared/config/newrelic.yml')
      instance.ssh!('! test -f /data/unused_newrelic_app/current/config/newrelic.yml')
    end
  end
end
