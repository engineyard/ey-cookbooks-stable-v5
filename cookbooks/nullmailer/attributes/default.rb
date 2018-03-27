#
# Cookbook Name:: nullmailer
# Attributes:: default
#

# Defines the SMTP server(s) to which you send email, and the protocol with which to access them.
default['nullmailer']['relayhost'] = "mail.#{node['domain']}"
default['nullmailer']['relay_proto'] = 'smtp'
default['nullmailer']['relay_options'] = {}

# Base mail information configuration
default['nullmailer']['me'] = node['fqdn']
default['nullmailer']['defaultdomain'] = node['domain']

# boolean flags to disable configuration file management
default['nullmailer']['configure']['me'] = true
default['nullmailer']['configure']['remotes'] = true
