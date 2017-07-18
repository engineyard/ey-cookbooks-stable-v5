module EngineyardDocker
  class OpenrcService < ::DockerCookbook::DockerServiceBase
    resource_name :docker_service_manager_openrc

    provides :docker_service_manager, platform: 'gentoo'

    action :start do
      # The group method is defined here as a property already
      declare_resource :group, 'docker' do
        system true
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

      service docker_name do
        provider Chef::Provider::Service::Gentoo
        supports restart: true, status: true
        action [:enable, :start]
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
