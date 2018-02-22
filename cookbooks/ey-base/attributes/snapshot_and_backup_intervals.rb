if snapshot_intervals = node['dna']['engineyard']['environment']['components'].find{|c| c['key'] == 'snapshot_intervals'}
  default['snapshot_hour']   = snapshot_intervals['snapshot_hour']
  default['snapshot_minute'] = snapshot_intervals['snapshot_minute']
  default['backup_hour']     = snapshot_intervals['backup_hour']
  default['backup_minute']   = snapshot_intervals['backup_minute']
end

# The snapshot intervals should always be given in dna.json, but provide
# fallbacks below in case it's ever not set. This is the logic that was present
# before EY started sending intervals to use via DNA.

node.set_unless['snapshot_hour'] = if ['24', ''].include?(node['backup_interval'].to_s)
  "9" # 0100 PDT, per support's request, instances run in UTC
else
  "*/#{node['backup_interval']}"
end

node.set_unless['snapshot_minute'] = '1'

node.set_unless['backup_hour'] = node['snapshot_hour']
node.set_unless['backup_minute'] = (node['snapshot_minute'].to_i + 10).to_s
