require 'chef/resource/package'
require 'chef/mixin/command'

class Chef
  class Resource
    class Package
      def at_least_version(version)
        package_name_str = @package_name || @name
        minimum_version = version
        status = ::Chef::Mixin::Command.popen4("portageq match / '>=#{package_name_str}-#{version}'") do  |pid, stdin, stdout, stderr|
          err = stderr.read
          raise err unless err =~ /^\s*$/
          candidate = stdout.read
          if candidate[0...(package_name_str.length)] == package_name_str
            minimum_version = candidate[(package_name_str.length+1)..-1].sub(/\s+\z/,'')
          end
        end
        minimum_version
      end
    end
  end
end
