#
# Cookbook Name:: sidekiq
# Recipe:: cleanup
#

# reload monit
execute "reload-monit" do
  command "monit quit && telinit q"
  action :nothing
end

if node['sidekiq']['is_sidekiq_instance']
  # report to dashboard
  ey_cloud_report "sidekiq" do
    message "Cleaning up sidekiq (if needed)"
  end

  # loop through applications
  node.dna['applications'].each do |app_name, _|
    # monit
    file "/etc/monit.d/sidekiq_#{app_name}.monitrc" do
      action :delete
      notifies :run, 'execute[reload-monit]'
    end

    # yml files
    node['sidekiq']['workers'].each_with_index do |_, count|
      file "/data/#{app_name}/shared/config/sidekiq_#{count}.yml" do
        action :delete
      end
    end
  end

  # bin script
  file "/engineyard/bin/sidekiq" do
    action :delete
  end

  # stop sidekiq
  execute "kill-sidekiq" do
    command "pkill -f sidekiq"
    only_if "pgrep -f sidekiq"
  end
end
