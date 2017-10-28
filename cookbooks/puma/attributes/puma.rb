default['puma'].tap do |puma|
  # Number of workers (not threads)
  puma['workers'] = node['cpu']['total']

  # sleep timeout
  puma['sleep_timeout'] = 4
end
