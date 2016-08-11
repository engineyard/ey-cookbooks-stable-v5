template '/engineyard/bin/env.sh' do
  owner 'root'
  group 'root'
  mode 0755
  variables :environment_name => node.engineyard.environment['name'],
            :stack            => node.engineyard.environment['stack_name'],
            :framework_env    => node.engineyard.environment['framework_env']
  source 'env.sh.erb'
end
