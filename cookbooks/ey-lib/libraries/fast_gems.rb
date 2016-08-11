class Chef
  class Recipe
    def has_gem?(name, version=nil)
      if !$GEM_LIST
        gems = {}
        Mixlib::ShellOut.new('gem list --local').each_line do |line|
          gems[$1.to_sym] = $2.split(/, /) if line =~ /^(.*) \(([^\)]*)\)$/
        end
        $GEM_LIST = gems
      end
      if $GEM_LIST[name.to_sym]
        if version
          if $GEM_LIST[name.to_sym].include?(version)
            Chef::Log.info("Gem: #{name}:#{version} already installed, skipping")
            return true
          end
        else
          Chef::Log.info("Gem: #{name} already installed, skipping")
          return true
        end
      end
      false
    end
  end
end
