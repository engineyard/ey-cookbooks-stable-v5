action = node.engineyard.metadata(:nginx_action,:restart)
using_openssl_101 = (node.engineyard.metadata('openssl_ebuild_version','1.0.1') =~ /1\.0\.1/)
default['nginx']['version'] = node.engineyard.metadata('nginx_ebuild_version','1.8.1-r1')
default['nginx']['action'] = action


Chef::Log.info("Version: #{nginx[:version]}, Passenger Gem:#{nginx[:passenger_gem]}\n")
