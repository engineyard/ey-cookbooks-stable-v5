module PostgresNineRecipe
  class SoloInstalled < EY::Sommelier::TestCase
    scenario :postgres9_solo

    def test_installed
      instance = instances(:solo)
      instance.ssh!("which psql")
    end

    def test_version
      instance = instances(:solo)
      output = instance.ssh("psql --version").stdout
      output.split("\n").each do |line|
        line.should =~ /(9.0.4)/
      end
    end
   
    def test_running
      instance = instances(:solo)
      instance.ssh!("/etc/init.d/postgresql-9.0 status")
    end
  end
  
end
