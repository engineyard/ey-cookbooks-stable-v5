case node.engineyard.environment['db_stack_name']
when /postgres/ 
  keyname = 'postgresql'
when /mysql/
  keyname = 'mysql'
end

owner = node[keyname]['owner']
dbroot = node[keyname]['dbroot']
datadir = node[keyname]['datadir']

managed_template "/engineyard/bin/local_key_copy.sh" do
  owner 'root'
  group 'root'
  mode 0700
  source "local_key_copy.sh.erb"
  variables(
    :keyname => keyname,
    :dbroot => dbroot
  )
end

# only on Solo and db_master
if ['solo','db_master'].include?(node.dna[:instance_role])
  managed_template "/engineyard/bin/db_server_ssl_keys.sh" do
    owner 'root'
    group 'root'
    mode 0700
    source "db_server_ssl_keys.sh.erb"
    variables(
      :db_owner => owner,
      :db_admin_pass => node.dna['users'].first['password'],
      :max_age => 365*5,
      :datadir => datadir,
      :replicas => (node.db_slaves || '').join(' '),
    )
  end
  
  execute "Setup Server SSL CA and root certificate" do
    command "/engineyard/bin/db_server_ssl_keys.sh"
    not_if { File.exists?(File.join(datadir, 'root.crt')) }
  end
  
  managed_template "/engineyard/bin/db_user_ssl_keys.sh" do
    owner 'root'
    group 'root'
    mode 0700
    source "db_user_ssl_keys.sh.erb"
    variables(    :max_age => 365*5,
      :datadir => datadir,
      :dbroot => dbroot,
      :keyname => keyname
    )
  end
  
  execute "Setup #{owner} user SSL key" do
    command "/engineyard/bin/db_user_ssl_keys.sh #{owner} #{node.dna['users'].first['password']} #{365*5}"
    only_if { File.exists?(File.join(datadir, 'root.crt')) }
    not_if { File.exists?(File.join(dbroot, 'keygen', owner, "#{keyname}.key")) }
  end
  
  execute "Setup #{node.dna['users'].first['username']} user SSL key" do
    command "/engineyard/bin/db_user_ssl_keys.sh #{node.dna['users'].first['username']} #{node.dna['users'].first['password']} #{365*5}"
    only_if { File.exists?(File.join(datadir, 'root.crt')) }
    not_if { File.exists?(File.join(dbroot, 'keygen', node.dna['users'].first['username'], "#{keyname}.key")) }
  end
  
  # replicas get special handling since sometimes we can't push the keys
  managed_template "/engineyard/bin/remote_key_copy.sh" do
    owner 'root'
    group 'root'
    mode 0700
    source "remote_key_copy.sh.erb"
    variables(    :max_age => 365*5,
      :keyname => keyname,
      :instances => (node.cluster - node.db_slaves).join(' '),
      :replicas => node.db_slaves.join(' '),
      :dbroot => dbroot,
      :datadir => datadir
    )
  end
  
  execute "Setup user SSL key on all instances" do
    command "/engineyard/bin/remote_key_copy.sh #{node.dna['users'].first['username']}"
    only_if { File.exists?(File.join(dbroot, 'keygen', node.dna['users'].first['username'], "#{keyname}.key")) }
  end
  

end
# needs to copy keys from ebs to home dirs
execute "Copy db ssl keys for #{owner} from EBS if available" do
  command "/engineyard/bin/local_key_copy.sh #{owner}"
  only_if { File.exists?(File.join(datadir, 'root.crt')) and
    File.exists?(File.join(dbroot, 'keygen', owner, "#{keyname}.key")) }
end

execute "Copy db ssl keys for #{node.dna['users'].first['username']} from EBS if available" do
  command "/engineyard/bin/local_key_copy.sh #{node.dna['users'].first['username']}"
  only_if { File.exists?(File.join(datadir, 'root.crt')) and
    File.exists?(File.join(dbroot, 'keygen', node.dna['users'].first['username'], "#{keyname}.key")) }
end
