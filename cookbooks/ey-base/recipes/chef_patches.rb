#
# Changes for Chef 12.7.2 and 12.10.24:
# YT-CC-1236: Rewrite candidate_version determination for increased speed and reduced complexity/error-chance.
# YT-CC-1244: Fix load_current_resource to correctly read version strings ending in a lower-case alpha character.
#

require 'chef/provider/package/portage'

ChefPatches = {
  '12.7.2' => [:candidate_version, :install_package, :load_current_resource],
  '12.10.24' => [:candidate_version, :install_package, :load_current_resource],
  '12.22.5' => [:candidate_version, :install_package, :load_current_resource]
}

unless ChefPatches.has_key?(Chef::VERSION)
  raise Chef::Exceptions::Package, "This version of Chef (#{Chef::VERSION}) may not correctly handle explicit portage categories -- see cookbooks/ey-base/recipes/chef_patches.rb"
end

if ChefPatches[Chef::VERSION].include? :load_current_resource
  class Chef::Provider::Package::Portage

    def load_current_resource
      @current_resource = Chef::Resource::Package.new(@new_resource.name)
      @current_resource.package_name(@new_resource.package_name)

      category, pkg = %r{^#{PACKAGE_NAME_PATTERN}$}.match(@new_resource.package_name)[1, 2]

      globsafe_category = category ? Chef::Util::PathHelper.escape_glob_dir(category) : nil
      globsafe_pkg = Chef::Util::PathHelper.escape_glob_dir(pkg)
      possibilities = Dir["/var/db/pkg/#{globsafe_category || "*"}/#{globsafe_pkg}-*"].map { |d| d.sub(%r{/var/db/pkg/}, "") }
      versions = possibilities.map do |entry|
	if entry =~ %r{[^/]+/#{Regexp.escape(pkg)}\-(\d[\.\d]*[a-z]?((_(alpha|beta|pre|rc|p)\d*)*)?(-r\d+)?)}
          [$&, $1]
        end
      end.compact

      if versions.size > 1
        atoms = versions.map { |v| v.first }.sort
        categories = atoms.map { |v| v.split("/")[0] }.uniq
        if !category && categories.size > 1
          raise Chef::Exceptions::Package, "Multiple packages found for #{@new_resource.package_name}: #{atoms.join(" ")}. Specify a category."
        end
      elsif versions.size == 1
        @current_resource.version(versions.first.last)
        Chef::Log.debug("#{@new_resource} current version #{$1}")
      end

      @current_resource
    end

  end
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
