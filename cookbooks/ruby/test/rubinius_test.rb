module RubyRecipe
  class RubiniusTest < EY::Sommelier::TestCase
    scenario :nibblier

    def test_ruby
      instance = instances(:solo)

      instance.ssh("ruby -v").stdout.chomp.should =~ /rubinius 2\.0/
    end

  end
end
