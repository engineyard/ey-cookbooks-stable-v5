#
# Cookbook Name:: resque-scheduler
# Recipe:: default
#
if node['resque_scheduler']['is_resque_scheduler_instance']
  node['dna']['applications'].each do |app, _data|
    template "/etc/monit.d/resque_scheduler_#{app}.monitrc" do
      owner 'root'
      group 'root'
      mode 0644
      source 'resque-scheduler.monitrc.erb'
      variables(
        app_name:  app,
        rails_env: node[:dna][:environment][:framework_env]
      )
    end

    cookbook_file "/data/#{app}/shared/bin/resque-scheduler" do
      source 'resque-scheduler'
      owner 'root'
      group 'root'
      mode 0755
      backup 0
    end
  end

  execute 'ensure-resque-is-setup-with-monit' do
    command %(
    monit reload
    )
  end
end
