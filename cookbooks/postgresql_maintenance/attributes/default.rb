default['postgresql_maintenance']['vacuumdb_cron_minute'] = '0'
default['postgresql_maintenance']['vacuumdb_cron_hour'] = '0'
default['postgresql_maintenance']['vacuumdb_cron_day'] = '*'
default['postgresql_maintenance']['vacuumdb_cron_month'] = '*'
default['postgresql_maintenance']['vacuumdb_cron_weekday'] = '0'

# this will vacuum all dbs
default['postgresql_maintenance']['vacuumdb_command'] = '/usr/bin/vacuumdb -U postgres --all'
