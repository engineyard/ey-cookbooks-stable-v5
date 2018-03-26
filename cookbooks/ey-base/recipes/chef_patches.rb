#
# Changes for Chef 12.7.2 and 12.10.24:
# YT-CC-1236: Rewrite candidate_version determination for increased speed and reduced complexity/error-chance.
#

require 'chef/provider/package/portage'

ChefPatches = {
  '12.7.2' => [:candidate_version, :install_package],
  '12.10.24' => [:candidate_version, :install_package]
}

unless ChefPatches.has_key?(Chef::VERSION)
  raise Chef::Exceptions::Package, "This version of Chef (#{Chef::VERSION}) may not correctly handle explicit portage categories -- see cookbooks/ey-base/recipes/chef_patches.rb"
end

if ChefPatches[Chef::VERSION].include? :candidate_version
  class Chef::Provider::Package::Portage

    def raise_error_for_query(msg)
      raise Chef::Exceptions::Package, "Query for '#{@new_resource.package_name}' #{msg}"
    end

    def candidate_version
      return @candidate_version if @candidate_version

      pkginfo = shell_out("portageq best_visible / #{@new_resource.package_name}")

      if pkginfo.exitstatus != 0
        pkginfo.stderr.each_line do |line|
          if line =~ /[Uu]nqualified atom .*match.* multiple/
            raise_error_for_query("matched multiple packages (please specify a category):\n#{pkginfo.inspect}")
          end
        end

        if pkginfo.stdout.strip.empty?
          raise_error_for_query("did not find a matching package:\n#{pkginfo.inspect}")
        end

        raise_error_for_query("resulted in an unknown error:\n#{pkginfo.inspect}")
      end

      if pkginfo.stdout.lines.count > 1
        raise_error_for_query("produced unexpected output (multiple lines):\n#{pkginfo.inspect}")
      end

      pkginfo.stdout.chomp!
      if pkginfo.stdout =~ /-r\d+$/
        # Latest/Best version of the package is a revision (-rX).
        @candidate_version = pkginfo.stdout.split(/(?<=-)/).last(2).join
      else
        # Latest/Best version of the package is NOT a revision (-rX).
        @candidate_version = pkginfo.stdout.split("-").last
      end

      @candidate_version
    end

  end
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
