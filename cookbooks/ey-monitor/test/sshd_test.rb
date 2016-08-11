module EyMonitorSshdRecipe
  class InittabTest < EY::Sommelier::TestCase
    scenario :alpha

    def test_monit_inittab_entries
      instance = instances(:solo)
      instance.ssh!("/etc/init.d/sshd stop ; sleep 65 ; /etc/init.d/sshd status")
    end
  end

  class DirtyInittabTest < EY::Sommelier::TestCase
    scenario :alpha
    destructive!

    def test_dirty_inittab_entry
      instance = instances(:solo)
      instance.ssh!("echo 'sm:345:respawn:/bin/false' >> /etc/inittab")
      redeploy(:solo)
      instance.ssh!(%q{[ "$(grep -c '^sm:' /etc/inittab)" == '1' ]})
    end
  end
end
