require 'chef/provider/package/portage'

ChefPatches = {
  '12.7.2' => [:install_package],
  '12.10.24' => [:install_package]
}

unless ChefPatches.has_key?(Chef::VERSION)
  raise Chef::Exceptions::Package, "This version of Chef (#{Chef::VERSION}) may not correctly handle explicit portage categories -- see cookbooks/ey-base/recipes/chef_patches.rb"
end

if ChefPatches[Chef::VERSION].include? :install_package

  class Chef::Provider::Package::Portage
    def install_package(name, version)
      pkg = "=#{name}-#{version}"

      if version =~ /^\~(.+)/
        # If we start with a tilde
        pkg = "~#{name}-#{$1}"
      end

      shell_out_with_timeout!( "emerge -g -n --color n --nospinner --quiet#{expand_options(@new_resource.options)} #{pkg}" )
    end
  end
end
