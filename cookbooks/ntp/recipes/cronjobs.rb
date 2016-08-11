# Make sure ntpd is reaching all peers on at least a daily basis.
cron "ntp_check" do
  minute    '2'
  hour      '*/6'
  command   '/engineyard/bin/ey-ntp-check'
  action :create
end

