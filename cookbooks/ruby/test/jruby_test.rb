module RubyRecipe
  class JRubyTest < EY::Sommelier::TestCase
    scenario :omicron

    def test_ruby
      instance = instances(:solo)

      instance.ssh("ruby -v").stdout.should =~ /^jruby 1.6.7/
    end
  end

end
