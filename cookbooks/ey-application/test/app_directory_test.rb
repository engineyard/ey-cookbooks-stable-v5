module EyApplicationRecipe
  class AppDirectoryTest < EY::Sommelier::TestCase
    scenario :alpha
    def test_cap_directories_created
      instance = instances(:solo)
      template.apps.each do |app|
        instance.ssh!("test -d /data/#{app.name}/shared")
        instance.ssh!("test -d /data/#{app.name}/shared/bin")
        instance.ssh!("test -d /data/#{app.name}/shared/config")
        instance.ssh!("test -d /data/#{app.name}/shared/pids")
        instance.ssh!("test -d /data/#{app.name}/shared/system")
        instance.ssh!("test -d /data/#{app.name}/releases")
      end
    end
  end
end
