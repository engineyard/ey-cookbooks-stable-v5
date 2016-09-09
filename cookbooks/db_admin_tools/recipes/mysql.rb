
include_recipe 'db_admin_tools::mytop'

if node.dna['instance_role'][/^(db|solo)/]
  include_recipe 'db_admin_tools::innotop'
  include_recipe 'db_admin_tools::percona_toolkit'
  include_recipe 'db_admin_tools::pwgen'
end

# Adding 'db_replica' attribute for future compatibility
if ['db_master', 'db_slave', 'db_replica'].include?(node.dna['instance_role'])
  include_recipe 'db_admin_tools::binary_logs'
end

if node.dna['instance_role'][/^(db|solo)/]
  template "/engineyard/bin/database_oom_adj" do
    owner 'root'
    group 'root'
    mode 0744
    source "database_oom_adj.sh.erb"
    variables({
     :service_scores => [
       ['sshd', -1000],
       ['mysqld', -900],
     ]
   })
 end

 cron "database_oom_score" do
   minute  '*/30'
   hour    '*'
   day     '*'
   month   '*'
   weekday '*'
   command '/engineyard/bin/database_oom_adj'
 end
end
