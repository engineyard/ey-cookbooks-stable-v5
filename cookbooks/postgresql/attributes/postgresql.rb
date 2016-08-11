default['default_statistics_target'] = "100"
default['max_fsm_pages'] = "500000"
default['max_fsm_relations'] = "10000"
default['logging_collector'] = "on"
default['log_rotation_age'] = "1d"
default['log_rotation_size'] = "100MB"
default['checkpoint_timeout'] = "5min"
default['checkpoint_completion_target'] = "0.5"
default['checkpoint_warning'] = "30s"
default['checkpoint_segments'] = "100"
default['wal_buffers'] = "8MB"
default['wal_writer_delay'] = "200ms"
default['max_stack_depth'] = "8MB"
default['total_memory'] = `cat /proc/meminfo`.scan(/^MemTotal:\s+(\d+)\skB$/).flatten.first.to_i * 1024
default['total_memory_mb'] = node['total_memory'] / 1024 / 1024
default['shared_memory_percentage'] = "0.25"
default['effective_cache_size_percentage'] = "0.80"
shared_buffers1 = node['total_memory_mb'] * shared_memory_percentage.to_f
if shared_buffers1.to_i > 17500
  default['shared_buffers'] = 17500
else
  default['shared_buffers']= shared_buffers1.to_i
end
effective_cache_size1 = node['total_memory_mb'] * node['effective_cache_size_percentage'].to_f
default['effective_cache_size'] = effective_cache_size1.to_i
if node['total_memory'] < 5147483648
    default['maintenance_work_mem'] = "128MB"
    default['work_mem'] = "32MB"
else
    default['maintenance_work_mem'] = "256MB"
    default['work_mem'] = "64MB"
end

default['lock_version_file'] = '/db/.lock_db_version'
