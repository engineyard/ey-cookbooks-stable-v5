module CronRecipe
  class CronNannyTwoTest < EY::Sommelier::TestCase
    scenario :alpha

    def test_cron_nanny_running
      instance = instances(:solo)
      instance.ssh!(%Q{pgrep "^cron_nanny$"})
    end

    # cron_nanny sleeps 60 seconds between loops, so we sleep more.
    def test_cron_nanny_restart_cron_if_pid_file_missing
      instance = instances(:solo)
      check_restarted=<<-EOC
        set -x
        set -e
        old_pid=$(< /var/run/cron.pid)
        rm /var/run/cron.pid
        sleep 121
        new_pid=$(< /var/run/cron.pid)
        test $new_pid -ne $old_pid
      EOC
      instance.ssh! check_restarted
    end


  end
end
