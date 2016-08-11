module NginxRecipe
  class SslCertTest < EY::Sommelier::TestCase
    scenario :delta
    destructive!

    def test_hit_rails_and_rack_urls
      instance = instances(:app_master)
      instance.ssh!("echo '127.0.0.1  rails.example.org' >> /etc/hosts")
      instance.ssh!("curl -Is -H 'Host: rails.example.org' https://rails.example.org/bench/stress --cacert /etc/nginx/ssl/rails.crt | grep 'HTTP/1.1 200 OK'")

      cert = template.apps.detect {|a| a.name == :rails }.ssl_cert
      cert.certificate = CERTIFICATE
      cert.private_key = PRIVATE_KEY

      redeploy(:app_master)

      tempfile = Tempfile.open('rails_secure.crt')
      tempfile << CERTIFICATE
      tempfile.flush

      remote_path = instance.ssh('mktemp -t cert.XXXXX').stdout.strip

      instance.scp(tempfile.path, remote_path)

      instance.ssh!("curl -Is -H 'Host: rails.example.org' https://rails.example.org/bench/stress --cacert #{remote_path} | grep 'HTTP/1.1 200 OK'")
    end

    CERTIFICATE = <<-CERT.gsub(/^\s+/, '')
      -----BEGIN CERTIFICATE-----
      MIIBrzCCARigAwIBAgIES986PzANBgkqhkiG9w0BAQUFADAcMRowGAYDVQQDDBFy
      YWlscy5leGFtcGxlLm9yZzAeFw0xMDA0MjYyMTAzNTlaFw0yMDA1MDMyMTAzNTla
      MBwxGjAYBgNVBAMMEXJhaWxzLmV4YW1wbGUub3JnMIGfMA0GCSqGSIb3DQEBAQUA
      A4GNADCBiQKBgQDG+0OlpxiW8YfhWVR0tfCDbWgCUbEIod0becD8QMHN/BHr5V6y
      mLSuMMZ71csFmG1Od31vNWQKvDvULdCOc5mf+p3f0xLyRyzOhGNMgLNtkJzUxFJv
      zjGOIovLGUjHGfL5KUgP7ruryx9wGvD/3GwnfxmCzIggpR/NjFEvbTeNNwIDAQAB
      MA0GCSqGSIb3DQEBBQUAA4GBAI6hiAoFFIlZjEkbqgjXzK6WxWOxj+ul6wsc2pcK
      m/yID/EPnJBf0K7l8zfChDTVckPQIz25p1ApJnALejZuY7Ft7rHP5XI68+2ttWfB
      8PQlWVTGgAvy+4guGYDVeWI2PYjeqGtUwJgEy030fRVvOc1/MeHvatLf5FwBxjXv
      4g0v
      -----END CERTIFICATE-----
    CERT

    PRIVATE_KEY = <<-KEY.gsub(/^\s+/, '')
      -----BEGIN RSA PRIVATE KEY-----
      MIICXgIBAAKBgQDG+0OlpxiW8YfhWVR0tfCDbWgCUbEIod0becD8QMHN/BHr5V6y
      mLSuMMZ71csFmG1Od31vNWQKvDvULdCOc5mf+p3f0xLyRyzOhGNMgLNtkJzUxFJv
      zjGOIovLGUjHGfL5KUgP7ruryx9wGvD/3GwnfxmCzIggpR/NjFEvbTeNNwIDAQAB
      AoGBAJ7kU/96sEMQeg30FGHiSz3X5p87dp/LCVIAZp/IYjpHWFRD49u/3z/dyRFo
      BmfgcSCggDSGsO11pFzpfMnT+85+6Is6n3Or0w8v1xQN8TI6VielCgWXpCYOsCK5
      q2lOYjiv44VNHBTQ0Z6Qn52gqB0suE6tb9MaB6sZh1GQNMoRAkEA+GOmwQAco4ay
      fsAEHer/TXvTg9QnLsMhIcCDkxCERYz8ZTgPJ8iyeCVQRe/z6hklWkghi9Y+Eujf
      /dQsjLV9TwJBAM0UD8xPGXZHeT1eRTxIm8H+nvEDhainUD2LNIkUrbcnJchcgRMs
      5wPJiZ/v/2heTKLe/d+HDh0DpGeGAvjlh5kCQQCyKchSZ2IjaVpe0Bwj2YuGaGsv
      A92XDR+Wth+qPQ6jVJ01fSBhyPM6eok5oQOzxpWkTFjDlMixh5gi2S2bQBLBAkAl
      m1IyUycGK6EuAcWMgnwdnQWkiNLP1K7AOnDN2n7ooUMqdNwumgNbDHAyZh5eEzzW
      eTHw9aE+7NYPLeIJpn2xAkEAuIKm51YDNt6gFE9sH57/o6FcgG1yHpukrpm031KD
      Xt/sMxPkXZISoebJMkfgYJ8wv2EARC/sTKPF0a7KiEgxvA==
      -----END RSA PRIVATE KEY-----
    KEY
  end
end
