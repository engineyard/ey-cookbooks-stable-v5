#!/usr/bin/env ruby

# Rewrite the comment below
# Very basic example of how to stop a given environment.
# For more info visit http://developer.engineyard.com 

require 'ey-core'
require 'optparse'
require 'logger'
#require 'yaml'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: stop_environment.rb [options]"

  opts.on('-a', '--account NAME', 'Account name') { |v| options[:account_name] = v }
  opts.on('-e', '--environment NAME', 'Environment name') { |v| options[:environment_name] = v }
  opts.on('-t', '--timeout NUMBER', 'Timeout for the operation, in seconds') { |v| options[:timeout] = v }

end.parse!

# Set up logger
logger = Logger.new("/var/log/ey-scheduled_scaling.log")

# Token comes from '~/.eyrc'
#eyrc = YAML.load_file(File.expand_path("~/.eyrc"))

#client = Ey::Core::Client.new(token: eyrc['api_token'])
client = Ey::Core::Client.new()

# Account name as shown in cloud.engineyard.com
account = client.accounts.first(name: options[:account_name])

# Environment's name
environment = account.environments.first(name: options[:environment_name])

if environment.servers.count == 0 then
  logger.error "Environment #{options[:environment_name]} doesn't have instances running, are you sure it isn't stopped already?"
  exit
end

logger.info "Stopping environment #{options[:environment_name]}...."
deprovision_request = environment.deprovision

# Stoping the environment with a timeout of 1200sec.
# Adjust as necessary depending of the size of the environment.
deprovision_request.ready!(Integer(options[:timeout]))

puts "-------------------"

if !deprovision_request.successful? then 
  logger.error "Stop environment FAILED!!!"
  logger.error "Check cloud.engineyard.com for more details"
  exit
end

logger.info "Stop environment #{options[:environment_name]} SUCCEDED!!!"

