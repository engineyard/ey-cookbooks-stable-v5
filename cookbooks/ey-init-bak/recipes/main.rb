require 'pp'
Chef::Log.info(ENV.pretty_inspect)

include_recipe 'ey-base::chef_patches'
include_recipe 'ey-base::resin_gems'
include_recipe 'ey-core'

include_recipe 'ey-base::bootstrap' # common things that are installed in all the instances
node.engineyard.instance.roles.each { |role| include_recipe "#{role}::prep" }
node.engineyard.instance.roles.each { |role| include_recipe "#{role}::build" }
include_recipe 'ey-base::post_bootstrap' # common things that we want to install setting up the instance
include_recipe 'app::create'
Chef::Log.info "roles: #{node.engineyard.instance.roles}"

include_recipe 'ey-custom::after-main'
