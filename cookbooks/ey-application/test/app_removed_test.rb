module EyApplicationRecipe
  class AppRemovedTest < EY::Sommelier::TestCase
    scenario :epsilon
    destructive!

    def test_removed_app_directories_deleted
      instance = instances(:solo)
      template.apps.each do |app|
        instance.ssh!("test -d /data/#{app.name}/")
      end

      template.apps.clear

      redeploy(:solo)

      template.apps.each do |app|
        instance.ssh!("! test -d /data/#{app.name}/")
      end
    end
  end
end
