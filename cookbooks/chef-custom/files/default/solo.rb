require 'open-uri'
require 'net/http'
# IMDSv2: under HttpTokens=required a tokenless metadata GET returns 401 and
# aborts chef-solo while loading this config. Get a session token first and
# fall back to a plain GET only if the token PUT fails. This file is plain
# Chef config, so cookbook libraries (EY::IMDS) are not loaded here.
imds_token = begin
  imds_http = Net::HTTP.new("169.254.169.254", 80)
  imds_http.open_timeout = 5
  imds_http.read_timeout = 5
  imds_res = imds_http.start do |c|
    c.request(Net::HTTP::Put.new("/latest/api/token", "X-aws-ec2-metadata-token-ttl-seconds" => "21600"))
  end
  (imds_res.is_a?(Net::HTTPSuccess) && !imds_res.body.to_s.empty?) ? imds_res.body : nil
rescue StandardError
  nil
end
cookbook_path     "/etc/chef-custom/recipes/cookbooks"
log_level         :info
file_store_path  "/etc/chef-custom/recipes/"
file_cache_path  "/etc/chef-custom/recipes/"
node_name OpenURI.open_uri("http://169.254.169.254/latest/meta-data/instance-id", imds_token ? { "X-aws-ec2-metadata-token" => imds_token } : {}).gets
Chef::Log::Formatter.show_time = false