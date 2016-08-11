require 'rubygems'
if File.join(File.dirname(__FILE__), "bin", "common.rb")
  require File.join(File.dirname(__FILE__), "bin", "common")
end
ENV["INLINEDIR"] = File.join(File.dirname(__FILE__), "tmp")
require 'merb-core'
Merb::Config.setup(:merb_root   => ".",
                   :environment => ENV['RACK_ENV'])
Merb.environment = Merb::Config[:environment]
Merb.root = Merb::Config[:merb_root]
Merb::BootLoader.run
run Merb::Rack::Application.new