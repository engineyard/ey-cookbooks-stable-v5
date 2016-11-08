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
  # and configuration for each worker.
  sidekiq['workers'] = [{

    # Concurrency (threads)
    'concurrency' => 25,

    # Queues
    # { :queue_name => priority }
    'queues' => {
      :default      => 1
    },

    # Memory Limit in MB (for Monit)
    'memory_limit' => 400
  }]

  # Verbose
  sidekiq['verbose'] = false
end
