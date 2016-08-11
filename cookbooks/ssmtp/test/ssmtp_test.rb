class SsmtpTest < EY::Sommelier::TestCase
  scenario :ssmtp

  def test_installed
    instance = instances(:solo)
    instance.ssh!("test -x /usr/sbin/ssmtp")
    result = instance.ssh("stat -c '%U:%G' /etc/ssmtp/ssmtp.conf")

    assert result.success?
    assert_equal "deploy:deploy", result.stdout.chomp
  end
end
