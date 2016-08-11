module CollectdRecipe
  class InittabTest < EY::Sommelier::TestCase
    scenario :alpha

    def test_collect_inittab_entries
      instance = instances(:solo)
      instance.ssh!("grep -q '^cd:345:respawn:/usr/sbin/collectd -C /etc/engineyard/collectd.conf -f' /etc/inittab")
    end
  end
end
