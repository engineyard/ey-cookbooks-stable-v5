module RubyRecipe
  class Ruby186Test < EY::Sommelier::TestCase
    scenario :alpha

    def test_ruby
      instance = instances(:solo)

      instance.ssh!("ruby -v | grep '1.8.6'")
      instance.ssh!("ruby -v | grep 'patchlevel 420'")
    end

  end
end
