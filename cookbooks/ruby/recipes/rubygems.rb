def ensure_rubygems_version
  rubygems = node.engineyard.environment.ruby.fetch(:rubygems,nil) if node.engineyard.environment.ruby?
  # Specific rubygems version must be set in the ruby component, see cookbooks/ey-core/dnapi.rb.

  if rubygems && (Gem::Version.new(`gem -v`) != Gem::Version.new(rubygems))
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
      command "update_rubygems"
    end

    # Avoid auto_gem load error
    execute "update env" do
      command "unset RUBYOPT; sudo env-update"
    end

  end
end

if node.engineyard.environment.ruby?  
  ensure_rubygems_version

  # TODO (jf): with ruby 2.6, bundler will be installed via portage.
  # So let's remove the package here as well (test if possible)

  # removing packaged bundler prevents the error "You must use Bundler 2 or greater with this lockfile"
  # engineyard-serverside installs bundler during deploys
  execute "remove bundler installed by rubygems" do
    command "rm -rf /usr/lib64/ruby/site_ruby/*/bundler{,.rb} && rm -f /usr/local/lib64/ruby/gems/*/specifications/default/bundler*gemspec"
  end
end
