#
# Cookbook Name:: thinking_sphinx_3
# Recipe:: cleanup
#

# Clean up sphinx on non-sphinx instances but not on db instances
if !node['sphinx']['is_thinking_sphinx_instance'] && !['db_master', 'db_slave'].include?(node['dna']['instance_role'])
 
  # reload monit
  execute "reload-monit" do
    command "monit quit && telinit q"
    action :nothing
  end

  # report to dashboard
  ey_cloud_report "sphinx" do
    message "Cleaning up sphinx (if needed)"
  end
  
  # loop through applications
  node['dna']['applications'].each do |app_name, _|
    # monit
    file "/etc/monit.d/sphinx_#{app_name}.monitrc" do 
      action :delete
      notifies :run, resources(:execute => "reload-monit")
      only_if "test -f /etc/monit.d/sphinx_#{app_name}.monitrc"
    end
  
    # remove cronjob
    cron "indexer-#{app_name}" do
      action :delete
    end
  end 

  # stop sphinx
  execute "kill-sphinx" do
    command "pkill -f searchd"
    only_if "pgrep -f searchd"
  end
end
