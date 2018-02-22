recipe = self
node.engineyard.apps.each do |app|
  template "/data/#{app.name}/shared/config/env" do
    owner node.engineyard.environment.ssh_username
    group node.engineyard.environment.ssh_username
    mode 0644
    variables({
      :app => app.name,
      :user => node.engineyard.environment.ssh_username,
      :type => app.app_type,
      :app_type => app.app_type,
      :framework_env => node['dna']['environment']['framework_env']
    })
    source "env.erb"
  end

  cookbook_file "/data/#{app.name}/shared/config/env.custom" do
    source "env.custom"
    owner node.engineyard.environment.ssh_username
    group node.engineyard.environment.ssh_username
    mode 0755
    backup 0
    not_if { FileTest.exists?("/data/#{app.name}/shared/config/env.custom") }
  end

  template "/engineyard/bin/app_#{app.name}" do
    owner node.engineyard.environment.ssh_username
    group node.engineyard.environment.ssh_username
    mode 0777
    source "unicorn.initd.sh.erb"
    variables({
      :app => app.name,
      :app_type => app.app_type,
      :user => node.engineyard.environment.ssh_username,
      :group => node.engineyard.environment.ssh_username,
    })
  end

  file "/etc/init.d/unicorn_#{app.name}" do
    action :delete
    backup 0

    not_if "test -h /etc/init.d/unicorn_#{app.name}"
  end

  link "/etc/init.d/unicorn_#{app.name}" do
    to "/engineyard/bin/app_#{app.name}"
  end

  depreciated_memory_limit = metadata_app_get_with_default(app.name, :app_memory_limit, "255.0")
  # See https://support.cloud.engineyard.com/entries/23852283-Worker-Allocation-on-Engine-Yard-Cloud for more details
  worker_memory_size = metadata_app_get_with_default(app.name, :worker_memory_size, depreciated_memory_limit)
  worker_termination_conditions = metadata_app_get_with_default(app.name, :worker_termination_conditions, {'quit' => [{}], 'term' => [{'cycles' => 8}]})
  base_cycles = (worker_termination_conditions.fetch('quit',[]).detect {|h| h.key?('cycles')} || {}).fetch('cycles',2).to_i

  worker_mem_cycle_checks = []
  %w(quit abrt term kill).each do |sig|
    worker_termination_conditions.fetch(sig,[]).each do |condition|
      overrun_cycles = condition.fetch('cycles',base_cycles).to_i
      mem = condition.fetch('memory',worker_memory_size).to_f
      worker_mem_cycle_checks << [mem, overrun_cycles, sig]
    end
  end

  template "/data/#{app.name}/shared/config/unicorn.rb" do
    owner node.engineyard.environment.ssh_username
    group node.engineyard.environment.ssh_username
    mode 0644
    variables(
      lazy {
        {
          :unicorn_instance_count => [recipe.get_pool_size / node['dna']['applications'].size, 1].max,
          :app => app.name,
          :type => app.app_type,
          :user => node.engineyard.environment.ssh_username
        }
      }
    )
    source "unicorn.rb.erb"
  end

  template "/etc/monit.d/unicorn_#{app.name}.monitrc" do
    owner node.engineyard.environment.ssh_username
    group node.engineyard.environment.ssh_username
    mode 0600
    source "unicorn.monitrc.erb"
    variables(
      lazy {
        {
          :app => app.name,
          :user => node.engineyard.environment.ssh_username,
          :app_type => app.app_type,
          :unicorn_worker_count => [recipe.get_pool_size / node['dna']['applications'].size, 1].max,
          :environment => node['dna']['environment']['framework_env'],
          :master_memory_size => worker_memory_size,
          :master_cycle_count => base_cycles,
          :worker_mem_cycle_checks => worker_mem_cycle_checks
        }
      }
    )
    backup 0

    notifies :run, 'execute[restart-monit]', :immediately
  end

  # cleanup extra unicorn workers
  bash "cleanup extra unicorn workers" do
    code lazy {
      <<-EOH
        for pidfile in /var/run/engineyard/unicorn_worker_#{app.name}_*.pid; do
          [[ $(echo "${pidfile}" | egrep -o '([0-9]+)' | tail -n 1) -gt #{recipe.get_pool_size - 1} ]] && kill -QUIT $(cat $pidfile) || true
        done
      EOH
    }
  end
end
