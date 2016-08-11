#
# Cookbook Name:: ec2
# Attribute:: ec2
#
# Copyright 2008, Engine Yard, Inc.
#
# All rights reserved - Do Not Redistribute
#

require 'net/http'

def get_from_ec2(thing="/")
  base_url = "http://169.254.169.254/latest/meta-data" + thing
  url = URI.parse(base_url)
  req = Net::HTTP::Get.new(url.path)
  res = Net::HTTP.start(url.host, url.port) {|http|
    http.request(req)
  }
  res.body
end

if attribute["domain"] =~ /\.amazonaws.com$/
  ec2 true
  get_from_ec2.split("\n").each do |key|
    attribute["ec2-#{key}"] = get_from_ec2("/#{key}")
  end
end
