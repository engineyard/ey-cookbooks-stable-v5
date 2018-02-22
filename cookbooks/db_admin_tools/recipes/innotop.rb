innotop_version = '1.9.1'

unmask_package "dev-db/innotop" do
  version innotop_version
  unmaskfile "innotop"
end

enable_package "dev-db/innotop" do
  version innotop_version
end

package "dev-db/innotop" do
  version innotop_version
  action :install
end

slaves_hostnames = node.engineyard.environment['instances'].collect do |i|
  [i[:name] ? i[:name] : i[:id], i[:public_hostname]] if i[:role] == 'db_slave'
end.compact!

slave_names = slaves_hostnames.map {|s| s[0]}
all_names = slave_names + ['master']

directory '/etc/innotop' do
  owner 'root'
  group 'root'
  mode 0755
end

template "/etc/innotop/innotop.conf" do
  owner 'root'
  group 'root'
  mode 0644
  source "innotop.conf.erb"
  variables ({
    :all_names => all_names.join(' '),
    :slave_names => slave_names.join(' '),
    :master_hostname => node.engineyard.environment['instances'].detect {|i| i[:role] =~ /db_master|solo/ }[:public_hostname],
    :slaves_hostnames => slaves_hostnames,
  })
end
