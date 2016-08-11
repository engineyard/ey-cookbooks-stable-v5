module RubyRecipe
  class Ruby192Test < EY::Sommelier::TestCase
    scenario :nibbly

    def test_ruby
      instance = instances(:solo)

      instance.ssh("ruby -v").stdout.should =~ /^ruby 1.9.2p320\s/
    end
  end
end
