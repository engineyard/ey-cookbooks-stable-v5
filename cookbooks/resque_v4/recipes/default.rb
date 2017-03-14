#
# Cookbook Name:: resque
# Recipe:: default
#
if node['resque']['is_resque_instance']
  execute 'install resque gem' do
    command 'gem install resque redis redis-namespace yajl-ruby -r'
    not_if { 'gem list | grep resque' }
  end

  node['dna']['applications'].each do |app, _data|
    template "/etc/monit.d/resque_#{app}.monitrc" do
      owner 'root'
      group 'root'
      mode 0644
      source 'monitrc.conf.erb'
      variables(
        num_workers: node['resque']['worker_count'],
        app_name:    app,
        rails_env:   node[:dna][:environment][:framework_env]
      )
    end

    node['resque']['worker_count'].times do |count|
      template "/data/#{app}/shared/config/resque_#{count}.conf" do
        owner node[:owner_name]
        group node[:owner_name]
        mode 0644
        source 'resque_wildcard.conf.erb'
      end
    end

    execute 'ensure-resque-is-setup-with-monit' do
      epic_fail true
      command %(
      monit reload
      )
    end
  end
end
