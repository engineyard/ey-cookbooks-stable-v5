#!/usr/bin/env ruby

# Very basic example of how to boot a given environment from a blueprint
# For more info visit http://developer.engineyard.com

require 'ey-core'
require 'optparse'
require 'logger'
#require 'yaml'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: boot_env.rb [options]"

  opts.on('-a', '--account NAME', 'Account name') { |v| options[:account_name] = v }
  opts.on('-e', '--environment NAME', 'Environment name') { |v| options[:environment_name] = v }
  opts.on('-b', '--blueprint NAME', 'Blueprint name') { |v| options[:blueprint_name] = v }
  opts.on('-i', '--ip X.X.X.X', 'Existing EIP address') { |v| options[:eip_address] = v}
  opts.on('-t', '--timeout NUMBER', 'Timeout for the operation, in seconds') { |v| options[:timeout] = v }

end.parse!

# Set up logger
logger = Logger.new("/var/log/ey-scheduled_scaling.log")

# Token comes from '~/.eyrc'
#eyrc = YAML.load_file(File.expand_path("~/.eyrc"))

#client = Ey::Core::Client.new(token: "abcdefghijklmnrstuvwxyz123456789")
#client = Ey::Core::Client.new(token: eyrc['api_token'])
client = Ey::Core::Client.new()

# Account name as shown in cloud.engineyarpd.com
account = client.accounts.first(name: options[:account_name])

# Environment's name
environment = account.environments.first(name: options[:environment_name])

if environment.servers.count > 0 then
  logger.error "Environment #{environment_name} has instances running, are you sure you want to boot it?"
  exit
end

# Get blueprint's name for cloud.engineyard.com
blueprint = environment.blueprints.first(name: options[:blueprint_name])
if !blueprint then
  logger.error "Could not find blueprint #{options[:blueprint_name]}"
  logger.error "Check cloud.engineyard.com for more details."
  exit
end

# Get EIP id for the provided address
eip = account.addresses.first(ip_address: options[:eip_address])
if !eip then
  logger.error "Could not find Elastick IP address #{options[:eip_address]}"
  logger.error "Check cloud.engineyard.com for more details."
  exit
end

env_options = {"blueprint_id": blueprint.id, "ip_id": eip.id}
logger.info "Booting environment #{options[:environment_name]} using blueprint #{options[:blueprint_name]} and ElasticIP #{options[:eip_address]} ...."
provision_request = environment.boot(env_options)

# Booting the environment instance with a timeout of 1800sec (30mins).
# Adjust as necessary depending of the size of the environment.
provision_request.ready!(Integer(options[:timeout]))

puts "-------------------"
if !provision_request.successful? then
  logger.error "Boot environment #{options[:environment_name]} FAILED!!!"
  logger.error "Check cloud.engineyard.com for more details"
  exit
end

logger.info "Boot environment #{options[:environment_name]} SUCCEDED!!!"
