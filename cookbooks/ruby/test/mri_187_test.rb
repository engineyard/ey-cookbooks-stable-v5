module RubyRecipe
  class Ruby187Test < EY::Sommelier::TestCase
    scenario :nibble

    def test_ruby
      instance = instances(:solo)

      instance.ssh!("ruby -v | grep '1.8.7'")
      instance.ssh!("ruby -v | grep 'patchlevel 352'")
    end

  end
end
