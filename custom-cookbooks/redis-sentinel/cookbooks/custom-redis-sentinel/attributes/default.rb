default['redis-sentinel'].tap do |sentinel|
  sentinel['port'] = '26379'

  # Install redis-sentinel on all app instances
  # sentinel['install_type'] = 'ALL_APP_INSTANCES'
  # Install redis-sentinel on all app and util instances
  # sentinel['install_type'] = 'ALL_APP_AND_UTIL_INSTANCES'

  # Install redis-sentinel on utility instances named 'sidekiq'
  #sentinel['utility_name'] = 'sidekiq'
  #sentinel['install_type'] = 'NAMED_UTILS'

  # Install redis-sentinel on all app instances, plus utility instances named 'sidekiq'
  sentinel['utility_name'] = 'sidekiq'
  sentinel['install_type'] = 'ALL_APP_AND_NAMED_UTIL_INSTANCES'

  # Timeout
  sentinel['timeout'] = 300_000
end
