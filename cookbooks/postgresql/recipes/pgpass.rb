template "/root/.pgpass" do
  backup 0
  mode 0600
  owner 'root'
  group 'root'
  source 'pgpass.erb'
  variables({
    :dbpass => node.engineyard.environment.ssh_password
  })
  only_if {['solo', 'db_master', 'db_slave'].include?(node.dna['instance_role'])}
end
