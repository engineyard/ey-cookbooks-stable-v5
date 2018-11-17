#
# Cookbook Name:: sidekiq
# Attrbutes:: default
#

default['sidekiq'].tap do |sidekiq|

  # Sidekiq will be installed on to application/solo instances,
  # unless a utility name is set, in which case, Sidekiq will
  # only be installed on to a utility instance that matches
  # the name
  sidekiq['is_sidekiq_instance'] = true

  # Number of workers (not threads)
  sidekiq['workers'] = 1

  # Concurrency
  sidekiq['concurrency'] = 25

  # Queues
  sidekiq['queues'] = {
    # :queue_name => priority
    :default => 1
  }

  # Memory limit
  sidekiq['worker_memory'] = 400 # MB

  # Verbose
  sidekiq['verbose'] = false

  # Setting this to true installs a cron job that
  # regularly terminates sidekiq workers that aren't being monitored by monit,
  # and terminates those workers
  #
  # default: false
  sidekiq['orphan_monitor_enabled'] = false

  # sidekiq_orphan_monitor cron schedule
  #
  # default: every 5 minutes
  sidekiq['orphan_monitor_cron_schedule'] = "*/5 * * * *"
end
