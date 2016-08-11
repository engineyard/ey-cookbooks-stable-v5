module EyApplicationRecipe
  class MyaqlYmlTest < EY::Sommelier::TestCase
    scenario :alpha
    def test_database_type_is_present
      instance = instances(:solo)
      template.apps.each do |app|
        instance.ssh!("grep mysql /data/#{app.name}/shared/config/database.yml")
      end
    end
  end

  class PostgresTest < EY::Sommelier::TestCase
    scenario :delta

    def test_postgresql_in_database_yml
      instance = instances(:app_master)

      template.apps.each do |app|
        instance.ssh!("grep postgresql /data/#{app.name}/shared/config/database.yml")
      end
    end
  end

  class Mysql2Test < EY::Sommelier::TestCase
    scenario :lambda

    def test_mysql2_in_database_yml
      instance = instances(:app_master)
      template.apps.each do |app|
        instance.ssh!("grep 'mysql2' /data/#{app.name}/shared/config/database.yml")
      end
    end
  end
end
