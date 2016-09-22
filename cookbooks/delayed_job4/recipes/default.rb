#
# Cookbook Name:: delayed_job
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

  node['delayed_job4']['applications'].each do |app_name|
    node['delayed_job4']['worker_count'].times do |count|
      template "/etc/monit.d/delayed_job#{count+1}.#{app_name}.monitrc" do
        source "dj.monitrc.erb"
        owner "root"
        group "root"
        mode 0644
        variables({
          :app_name => app_name,
          :user => node[:owner_name],
          :worker_name => "#{app_name}_delayed_job#{count+1}",
          :framework_env => node[:dna][:environment][:framework_env]
        })
      end
    end
      
    execute "monit reload" do
       action :run
       epic_fail true
    end
      
  end
end
