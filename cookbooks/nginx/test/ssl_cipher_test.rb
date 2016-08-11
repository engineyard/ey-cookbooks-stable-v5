module NginxRecipe
  class SslCipherTest < EY::Sommelier::TestCase
    scenario :delta
    destructive!

    def test_sslv2_ciphers
      instance = instances(:app_master)
      instance.ssh!("echo '127.0.0.1  rails.example.org' >> /etc/hosts")
      instance.ssh!("T=$(for v2 in `openssl ciphers SSLv2 -v|awk '{print $1}'`; do echo|openssl s_client -ssl2 -cipher $v2 -connect rails.example.com:443 2>&1|grep errno;done);[ \"${#T}\" -gt \"0\" ]")
    end
  end
end
