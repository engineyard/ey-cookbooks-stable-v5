include_recipe 'ey-monitor::sshd'
include_recipe 'ey-monitor::cron'

case node['dna']['instance_role'].to_sym
when :app_master, :app
  include_recipe 'ey-monitor::client'
end
