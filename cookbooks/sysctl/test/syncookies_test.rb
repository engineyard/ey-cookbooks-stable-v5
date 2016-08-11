module Sysctl
  class Syncookies64bitTest < EY::Sommelier::TestCase
    scenario :epsilon

    def test_syncookies_enabled
      instance = instances(:solo)
      instance.ssh!('[ "$( sysctl -n -e net.ipv4.tcp_syncookies)" == "1" ]')
    end
  end

  class Syncookies32bitTest < EY::Sommelier::TestCase
    scenario :alpha

    def test_syncookies_disabled
      instance = instances(:solo)
      instance.ssh!('[ -z "$( sysctl -n -e net.ipv4.tcp_syncookies)" ]')
    end
  end
end
