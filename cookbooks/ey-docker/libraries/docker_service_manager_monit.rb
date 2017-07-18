module EngineyardDocker
  class DockerServiceManagerMonit < ::DockerCookbook::DockerServiceBase
    resource_name :docker_service_manager_monit

    provides :docker_service_manager, platform: 'gentoo'

    action :start do
      # The group method is defined here as a property already
      declare_resource :group, 'docker' do
        system true
      end

      # enable IPv4 forwarding instead of letting docker do it
      sysctl "net.ipv4.ip_forward" do
        variables "net.ipv4.ip_forward" => 1
      end

      template "/etc/conf.d/#{docker_name}"  do
        source 'docker.confd.erb'
        variables config: new_resource,
                  docker_daemon_opts: docker_daemon_opts.join(' ')
        cookbook 'engineyard_docker'
      end

      template "/etc/init.d/#{docker_name}" do
        source 'docker.initd.erb'
        cookbook 'engineyard_docker'
        mode '0755'
      end

      execute "monit reload" do
        action :nothing
      end
      
      template '/etc/monit.d/docker.monitrc' do
        cookbook 'engineyard_docker'
        source 'docker.monitrc.erb'
        variables pidfile: pidfile
        notifies :run, resources(:execute => "monit reload"), :immediately
      end

      bash "check if docker is running for a maximum of 1 minute" do
        code <<-EOH
          for i in {1..12}
          do
            docker info
            if [ $? -eq 0 ]; then
              break
            fi
            sleep 5
          done
        EOH
        not_if "docker info"
      end
    end

    def docker_daemon_opts
      opts = super
      opts.delete_if { |opt| opt =~ /--pidfile/ }
      opts
    end

    # FIXME Remove after upstream's merged
    # https://github.com/chef-cookbooks/docker/pull/726
    def dockerd_bin
      '/usr/bin/dockerd'
    end
  end
end

