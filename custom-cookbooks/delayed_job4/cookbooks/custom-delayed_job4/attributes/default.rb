default['delayed_job4']['is_dj_instance'] = (node['dna']['instance_role'] == 'util' && node['dna']['name'] == 'delayed_job')
# default['delayed_job4']['applications'] = %w[todo]
#default['delayed_job4']['worker_count'] = 4

# The config below is for a single app per environment
# Improvement:  make it so that DJ for multiple apps per env can be configured
# in a way that each has it own set of workers with its own memory limit, and then queues per worker

# Memory per worker, going above this value will trigger monit to restart the worker
# Same value for all workers
# Improvement:  set the memory limit per worker
default['delayed_job4']['worker_memory'] = 2000

# Defining number of workers per queue
# so to spin up a process for each worker and configure queues to be run for ti
# values below are examples

default['delayed_job4']['queues'] = {
  # :queue_name => number of workers
  :my_queue => 3,
  :his_queue => 1,
  :her_queue => 2,
  :their_queue => 1
}
