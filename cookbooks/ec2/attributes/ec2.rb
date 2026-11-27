#
# Cookbook Name:: ec2
# Attribute:: ec2
#
# Copyright 2008, Engine Yard, Inc.
#
# All rights reserved - Do Not Redistribute
#

require 'net/http'

# IMDSv2-aware (see ey-lib libraries/imds.rb; ec2 depends on ey-lib). Under
# HttpTokens=required the old tokenless Net::HTTP GET returned the 401 body,
# which was then stored as attribute names/values. On any fetch error return
# an empty string, so no error text is ever stored as metadata.
def get_from_ec2(thing="/")
  ::EY::IMDS.get("latest/meta-data" + thing)
rescue StandardError
  ""
end

if attribute["domain"] =~ /\.amazonaws.com$/
  ec2 true
  get_from_ec2.split("\n").each do |key|
    attribute["ec2-#{key}"] = get_from_ec2("/#{key}")
  end
end
