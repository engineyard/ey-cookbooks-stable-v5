def ensure_rubygems_version
  rubygems = node.engineyard.environment.ruby.fetch(:rubygems,nil) if node.engineyard.environment.ruby?
  # Specific rubygems version must be set in the ruby component, see cookbooks/ey-core/dnapi.rb.
  # Only Ruby 1.8.6 should need a specific version

  if rubygems && (Gem::Version.new(`gem -v`) != Gem::Version.new(rubygems))
    # set rubygem update command
    # JRuby and Rubinius don't have update_rubygems in the path,
    # so we look for it in the environment

    if node.engineyard.environment.jruby?
      update_command = 'ruby -S update_rubygems'
    else
      # 1.5.2 is a "special needs" version, since gem system update syntax changed from that version and up.
      # sort -t. -k1,1n -k2,2n -k3,3n -k4,4n is used to do a version sort, and if 1.5.2 is the lesser of the
      # two versions, then it needs to use the new syntax

      update_command =<<-EOF
      gem_version=`gem -v`
      if [[ "$(printf "1.5.2\\n$gem_version" | sort -t. -k1,1n -k2,2n -k3,3n -k4,4n | head -n1)" == "1.5.2" ]] ; then gem update --system #{rubygems}; else update_rubygems; fi
      EOF
    end

    # Uninstall previously installed version of Rubygems
    #  TODO: uninstall ALL versions of rubygems -- the below code won't work if there are multiple versions installed
    ruby_block "uninstall previous versions of rubygems" do
      block do
        output = Mixlib::ShellOut.new('gem list rubygems').run_command.stdout
        matchdata = output.match(/\(([^\)]*)\)/)
        if versions = (matchdata && matchdata[1])
          versions.split(',').each do |version|
            version.strip!
             if version != rubygems
               Mixlib::ShellOut.new('gem uninstall rubygems-update -v #{version}')
             end
          end
        else
          Mixlib::ShellOut.new('gem install rubygems-update -v #{rubygems}')
        end
      end
    end

    ey_cloud_report "rubygems update" do
      message "installing Rubygems #{rubygems}"
    end

    execute "install rubygems #{rubygems}" do
      command "gem install rubygems-update -v #{rubygems}"
    end

    execute "update rubygems to >= #{rubygems}" do
      command update_command
    end

    # Avoid auto_gem load error
    execute "update env" do
      command "unset RUBYOPT; sudo env-update"
    end

  end
end

if node.engineyard.environment.ruby?
  if node.engineyard.environment.jruby?
    # If this is a JRuby instance and RubyGems is at version 1.5.2,
    # we have already overwritten the built-in gem with a lesser
    # version.
    # To get the version of RubyGems that works, we need to uninstall
    # and re-install jruby-bin
    if Mixlib::ShellOut.new('gem -v') =~ /\b1\.5\.2\b/
      package 'dev-java/jruby-bin' do
        action :remove
      end
      package 'dev-java/jruby-bin' do
        action :install
        version node.engineyard.environment.ruby['version']
      end
    end
  else
    ensure_rubygems_version
  end

  # removing packaged bundler prevents the error "You must use Bundler 2 or greater with this lockfile"
  # engineyard-serverside installs bundler during deploys
  execute "remove bundler installed by rubygems" do
    command "rm -rf /usr/lib64/ruby/site_ruby/*/bundler{,.rb} && rm -f /usr/local/lib64/ruby/gems/*/specifications/default/bundler*gemspec"
  end
end
