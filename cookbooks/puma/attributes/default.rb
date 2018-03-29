# Setting workers count = CPU cores count
default['puma']['workers'] = node['cpu']['total']
# Setting default pumas service restart timeout
default['puma']['sleep_timeout'] = 4
