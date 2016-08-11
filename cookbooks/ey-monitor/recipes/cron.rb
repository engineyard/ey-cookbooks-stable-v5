# Monitor cron
inittab "cm" do
  command %q{/engineyard/bin/cron_nanny}
end
