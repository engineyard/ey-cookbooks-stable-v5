default['redis'].tap do |redis|
  redis['version'] = '3.2.6'
  redis['download_url'] = 'http://download.redis.io/releases/redis-3.2.6.tar.gz'
  redis['port'] = '6379'
  redis['basedir'] = '/data/redis'

  # Redis 4.0.alpha, for the adventurous
  #redis['version'] = '4.0-rc2'
  #redis['download_url'] = 'https://github.com/antirez/redis/archive/4.0-rc2.tar.gz'

  redis['force_upgrade'] = false

  # Run Redis on a named util instance
  # This is the default
  redis['utility_name'] = 'redis'
  redis['is_redis_instance'] = (
    node['dna']['instance_role'] == 'util' &&
    node['dna']['name'] == redis['utility_name']
  )

  # Run redis on a solo instance
  # Not recommended for production environments
  #redis['is_redis_instance'] = (node['dna']['instance_role'] == 'solo')

  # Log level options:
  # - debug
  # - verbose
  # - notice
  # - warning
  redis['loglevel'] = 'notice'
  redis['logfile'] = '/data/redis/redis.log'

  # Timeout
  redis['timeout'] = 300000

  # Where to save the RDB file
  redis['rdb_filename'] = 'dump.rdb'

  # Save frequency
  #
  # In the example below the behaviour will be to save:
  # after 900 sec (15 min) if at least 1 key changed
  # after 300 sec (5 min) if at least 10 keys changed
  # after 60 sec if at least 10000 keys changed
  redis['saveperiod'] = [
    "900 1",
    "300 10",
    "60 10000"
  ]

  # Set the number of databases. The default database is DB 0, you can select
  # a different one on a per-connection basis using SELECT <dbid> where
  # dbid is a number between 0 and 'databases'-1
  redis['databases'] = 16

  # Compress string objects using LZF when dump .rdb databases?
  # For default that's set to 'yes' as it's almost always a win.
  # If you want to save some CPU in the saving child set it to 'no' but
  # the dataset will likely be bigger if you have compressible values or keys.
  redis['rdbcompression'] = 'yes'

  # Redis calls an internal function to perform many background tasks, like
  # closing connections of clients in timeout, purging expired keys that are
  # never requested, and so forth.
  #
  # Not all tasks are performed with the same frequency, but Redis checks for
  # tasks to perform according to the specified "hz" value.
  #
  # By default "hz" is set to 10. Raising the value will use more CPU when
  # Redis is idle, but at the same time will make Redis more responsive when
  # there are many keys expiring at the same time, and timeouts may be
  # handled with more precision.
  #
  # The range is between 1 and 500, however a value over 100 is usually not
  # a good idea. Most users should use the default of 10 and raise this up to
  # 100 only in environments where very low latency is required.
  redis['hz'] = 10
end
