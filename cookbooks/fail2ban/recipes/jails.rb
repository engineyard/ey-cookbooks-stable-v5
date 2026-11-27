#
# Cookbook Name:: fail2ban
# Recipe:: jails
#
#

# We need net/http (token PUT) and open-uri (fail-loud GET) for IMDS.
require 'net/http'
require 'open-uri'
require 'timeout'

# Fetch an EC2 instance metadata value using IMDSv2 (token handshake) with a
# plain-GET fallback. Under HttpTokens=required a plain unauthenticated IMDSv1
# GET returns 401. If the token PUT fails we fall back to an unauthenticated
# GET. Mirrors the Stack v8 ey-fail2ban helper, using OpenURI.open_uri because
# URI.open needs Ruby 2.5+ and this stack runs Ruby 2.2.
#
# IMPORTANT: this MUST fail loud on an error response. The fetched value flows
# into fail2ban's `ignoreip` allow-list; Net::HTTP.get (used here before)
# returns the body whatever the status, so a 401 error page would have been
# written into config. OpenURI raises OpenURI::HTTPError on any non-2xx. A 404
# is treated as legitimate absence (no public IPv4 assigned) and returns nil.
def imds_get(path)
  base = 'http://169.254.169.254'
  token = begin
    uri = URI("#{base}/latest/api/token")
    req = Net::HTTP::Put.new(uri.request_uri)
    req['X-aws-ec2-metadata-token-ttl-seconds'] = '21600'
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 5
    http.read_timeout = 5
    res = http.start { |connection| connection.request(req) }
    res.is_a?(Net::HTTPSuccess) && !res.body.to_s.empty? ? res.body : nil
  rescue StandardError
    nil
  end
  headers = token ? { 'X-aws-ec2-metadata-token' => token } : {}
  headers[:read_timeout] = 5
  Timeout.timeout(5) do
    OpenURI.open_uri("#{base}/#{path}", headers) { |io| io.read }
  end
rescue OpenURI::HTTPError => e
  # 404 = key legitimately absent. Anything else (401/403, 5xx) is a real
  # error we must NOT swallow into config.
  return nil if e.io.status.first == '404'
  raise
end

ey_cloud_report "Fail2Ban-filter-action" do
  message "Fail2Ban action & filter"
end

public_ip = imds_get('latest/meta-data/public-ipv4').to_s.strip
# Basic IPv4 sanity check, so a malformed value can never reach `ignoreip`.
# An empty value means no public IPv4 is assigned (404 above).
raise "fail2ban: IMDS returned a malformed public-ipv4 (#{public_ip.inspect})" unless public_ip.empty? || public_ip =~ /\A\d{1,3}(?:\.\d{1,3}){3}\z/

def pushFile(fileList, type)
	refPath = "#{Chef::Config['file_cache_path']}cookbooks/fail2ban/files"
	files = fileList.select {|w| w[/#{type}\.d/]}
	files.each do |filepath|
		filename = filepath.match(/#{refPath}\/.*\/#{type}\.d\/(.*)/)
		filename = "#{type}.d/#{filename[1]}"
		cookbook_file "/etc/fail2ban/#{filename}" do
			source filename # filename instead of filepath in the case of a platform specific stuff
			owner 'root'
			group 'root'
			mode "0644"
			action :create #:create_if_missing
		end
	end
end

def pushFileTemplates(fileList, type)
	refPath = "#{Chef::Config['file_cache_path']}cookbooks/fail2ban/templates"
	files = fileList.select {|w| w[/#{type}\.d/]}
	files.each do |filepath|
		filename = filepath.match(/#{refPath}\/.*\/#{type}\.d\/(.*)/)
		filename = "#{type}.d/#{filename[1]}"
		template "/etc/fail2ban/#{filename}" do
			source filename
			owner 'root'
			group 'root'
			mode "0644"
			variables({
				:public_ip  => public_ip,
				:private_ip => node['ipaddress'],
				:host       => node['hostname']
			})
			action :create #:create_if_missing
		end
	end
end

# list file to upload for action and filter try for the templates too
# @see http://lists.opscode.com/sympa/arc/chef/2011-09/msg00271.html
#files = run_context.cookbook_collection[ cookbook_name ].template_filenames
#pushFileTemplates(files, 'filter')
#pushFileTemplates(files, 'action')

files = run_context.cookbook_collection[ cookbook_name ].file_filenames
pushFile(files, 'filter')
pushFile(files, 'action')

#
# Now that we have filter and action deployed, we can configure the jail
#

ey_cloud_report "Fail2Ban-jail-conf" do
  message "Fail2Ban jails"
  Chef::Log.info "Fail2Ban jails configuration"
end


template '/etc/fail2ban/jail.local' do
  source 'jail.local.erb'
  action :create
  variables({
    :jails      => node['fail2ban']['jails']['jails'],
    :ignoreip   => node['fail2ban']['jails']['ignoreip'] + ' ' + node['ipaddress'] + ' ' + public_ip,
    :bantime    => node['fail2ban']['jails']['bantime'],
    :findtime   => node['fail2ban']['jails']['findtime'],
    :maxretry   => node['fail2ban']['jails']['maxretry'],
    :backend    => node['fail2ban']['jails']['backend'],
    :mail       => node['fail2ban']['jails']['mail'],
    :usedns     => node['fail2ban']['jails']['usedns'],
    :ignorecommand     => node['fail2ban']['jails']['ignorecommand'],
    :host       => node['hostname'],
    :actions    => node['fail2ban']['jails']['actions'],
    :banaction  => node['fail2ban']['jails']['banaction'],
    :mta        => node['fail2ban']['jails']['mta'],
    :protocol   => node['fail2ban']['jails']['protocol']
  })
  owner 'root'
  group 'root'
  mode 0644
  notifies :restart, 'service[fail2ban]'
end


#if app_server? || util?
#
#end

# http://serverfault.com/questions/460442/chef-multiple-files-dynamic-template-resource
# http://docs.getchef.com/chef/dsl_recipe.html
