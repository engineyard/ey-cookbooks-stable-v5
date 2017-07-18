module EngineyardDocker
  class InstallationPackage < ::DockerCookbook::DockerInstallationPackage
    resource_name :docker_installation_package_ebuild

    provides :docker_installation_package, platform: 'gentoo'

    # Override upstream defaults
    property :package_name, String, default: 'app-emulation/docker', desired_state: false
    property :package_version, String, default: '1.7.1', desired_state: false
  end
end
