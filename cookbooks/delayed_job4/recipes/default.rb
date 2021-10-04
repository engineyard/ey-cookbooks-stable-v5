#
# Cookbook Name:: delayed_job4
# Recipe:: default
#

if node['delayed_job4']['is_dj_instance']
  directory "/engineyard/custom" do
    owner "root"
    group "root"
    mode 0755
  end

  template "/engineyard/custom/dj" do
    source "dj.erb"
    owner "root"
    group "root"
    mode 0755
  end

  # Only one app per env by now
  # Improvement:  have it loop across all apps on the env
  
  app_name = node['delayed_job4']['applications'].first

  # The queues per worker definition is send as-is to the .erb template
  # to be processed there
  
  template "/etc/monit.d/delayed_job.#{app_name}.monitrc" do
    source "dj.monitrc.erb"
    owner "root"
    group "root"
    mode 0644
    variables({
                :app_name => app_name,
                :user => node[:owner_name],
                :queues => node['delayed_job4']['queues'],
                :framework_env => node[:dna][:environment][:framework_env],
                :worker_memory => node['delayed_job4']['worker_memory']
              })
  end

  execute "monit reload" do
    action :run
    epic_fail true
  end

end
