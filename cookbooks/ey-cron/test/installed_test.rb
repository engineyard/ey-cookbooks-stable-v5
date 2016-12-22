module CronRecipe
  class InstalledTest < EY::Sommelier::TestCase
    scenario :alpha

    def test_cron_running
      instance = instances(:solo)
      instance.ssh!(%Q{pgrep "^cron$"})
    end

    def test_cron_check_crontab
      instance = instances(:solo)
      instance.ssh! %Q{grep '\* \* \* \* \* touch /tmp/cron-check' /var/spool/cron/crontabs/root}
    end
  end
end
