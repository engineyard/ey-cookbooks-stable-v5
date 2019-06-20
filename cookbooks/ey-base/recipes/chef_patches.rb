#
# Changes for Chef 12.7.2 and 12.10.24:
# YT-CC-1236: Rewrite candidate_version determination for increased speed and reduced complexity/error-chance.
# YT-CC-1244: Fix load_current_resource to correctly read version strings ending in a lower-case alpha character.
# YT-CC-1352: Add support for rubygems 3.x by using the correct flags (`--no-ri --no-rdoc` or `--no-document`) based on the rubygems version.
#

require 'chef/provider/package/portage'

ChefPatches = {
  '12.7.2' => [:candidate_version, :install_package, :load_current_resource, :rubygems_3x_support],
  '12.10.24' => [:candidate_version, :install_package, :load_current_resource, :rubygems_3x_support]
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

if ChefPatches[Chef::VERSION].include? :rubygems_3x_support
  class Chef::Provider::Package::Rubygems
    class GemEnvironment
      def rubygems_version
        raise NotImplementedError
      end
    end

    class CurrentGemEnvironment
      def rubygems_version
        Gem::VERSION
      end
    end

    class AlternateGemEnvironment
      def rubygems_version
        @rubygems_version ||= shell_out!("#{@gem_binary_location} --version").stdout.chomp
      end
    end

    def install_via_gem_command(name, version)
      if @new_resource.source =~ /\.gem$/i
        name = @new_resource.source
        src = " --local" unless source_is_remote?
      elsif @new_resource.clear_sources
        src = " --clear-sources"
        src << (@new_resource.source && " --source=#{@new_resource.source}" || "")
      else
        src = @new_resource.source && " --source=#{@new_resource.source} --source=#{Chef::Config[:rubygems_url]}"
      end
      if !version.nil? && version.length > 0
        shell_out_with_timeout!("#{gem_binary_path} install #{name} -q #{rdoc_string} -v \"#{version}\"#{src}#{opts}",
:env => nil)
      else
        shell_out_with_timeout!("#{gem_binary_path} install \"#{name}\" -q #{rdoc_string} #{src}#{opts}", :env => nil)
      end
    end

    private

    def rdoc_string
      if needs_nodocument?
        "--no-document"
      else
        "--no-rdoc --no-ri"
      end
    end
    
    def needs_nodocument?
      Gem::Requirement.new(">= 3.0.0.beta1").satisfied_by?(Gem::Version.new(gem_env.rubygems_version))
    end
  end
end
