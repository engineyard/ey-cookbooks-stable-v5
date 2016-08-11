
include_recipe 'db_admin_tools::pg_top'

if node.dna[:instance_role][/^(db|solo)/]
  template "/engineyard/bin/database_oom_adj" do
    owner 'root'
    group 'root'
    mode 0744
    source "database_oom_adj.sh.erb"
    variables({
     :service_scores => [
       ['sshd', -1000],
       ['postgres', -900],
    ]})
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
