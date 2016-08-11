module RubyRecipe
  class REETest < EY::Sommelier::TestCase
    scenario :nibbler

    def test_ruby
      instance = instances(:solo)

      instance.ssh!("ruby -v | grep 'Ruby Enterprise Edition 2012.02'")
    end

  end
end
