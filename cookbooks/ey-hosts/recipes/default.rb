# Utility instances by instance name (ey-utility-#{name}[-X]) where X is some number if name is not unique
utility_nodes = node.engineyard.environment.instances.select{|i| ['util'].include?(i['role'])}.map {|i| {"ey-utility-#{i['name']}".gsub(/-$/, '') => node.private_ip_for(i)}}.each_with_object({}) { |el, h| el.each { |k, v| k='' if k.nil?; h[k].nil? ? h[k] = v : h[k] = (Array.new([h[k]]) << v).flatten } }

# DB Replicas by instance name (ey-db-slave-#{name}[-X]) where X is some number if name is not unique
db_replicas = node.engineyard.environment.instances.select{|i| ['db_slave'].include?(i['role']) and !(i['name'].nil? or i['name'] == '')}.map {|i| {"ey-db-slave-#{i['name']}".gsub(/-$/, '') => node.private_ip_for(i)}}.each_with_object({}) { |el, h| el.each { |k, v| k='' if k.nil?; h[k].nil? ? h[k] = v : h[k] = (Array.new([h[k]]) << v).flatten } }

template "/etc/ey_hosts" do
  owner 'root'
  group 'root'
  mode 0644
  source "ey_hosts.erb"
  variables({
    :utility_nodes => utility_nodes,
    :db_replicas => db_replicas,
    :db_replicas_ordered => node.db_slaves || '',
    :db_master => node.db_master[0] || '',
    :app_master => node.app_master[0] || '',
    :app_slaves => node.app_slaves || ''
  })
end

execute "Add EY-HOSTS section to hosts if it doesn't exist" do
  user "root"
  command "echo '#---EY-HOSTS-START
#---EY-HOSTS-END
' >> /etc/hosts"
  not_if "grep 'EY-HOSTS-START' /etc/hosts"
end

execute "Update ey-hosts entries" do
  user "root"
  command 'perl -0777 -i -pe "s/(#---EY-HOSTS-START\\n).*(#---EY-HOSTS-END)/\$1`cat /etc/ey_hosts`\n\n\$2/s" /etc/hosts'
end
