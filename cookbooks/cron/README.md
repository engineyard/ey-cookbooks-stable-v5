cron
========

Sets up cron jobs specific to the EY Stack on top of whatever ones are defined on the AMI:
 - sets env variables PATH, RAILS_ENV, RACK_ENV on both root's and deploy's crontab
 - adds cronjob for executing ey-snapshot.
 - adds cronjob for executing eix-sycn
 - add cronjobs that were configured through the web UI.
 - installs cron_nanny to watch over cron and configures it.
