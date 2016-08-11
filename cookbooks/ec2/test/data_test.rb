module Ec2Recipe
  class DataPartitionTest < EY::Sommelier::TestCase
    scenario :alpha

    def test_sdz1_is_data
      instance = instances(:solo)

      instance.ssh!("df | grep /dev/sdz1 | grep /data")
    end
  end
end
