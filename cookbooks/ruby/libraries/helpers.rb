module RubyHelpers
  def ruby2x?(x, version_string)
    version_string =~ /^2\.#{x}\.[\d\.]*\b/
  end

  def ruby_minor_version(version_string)
    version_string.split('.')[1]
  end

  def ruby2x_mask(version_string)
    "-ruby_targets_ruby2#{ruby_minor_version(version_string)}"
  end

  def get_installed_ruby2x_slots
    cmd = Mixlib::ShellOut.new("equery l -F '$slot' dev-lang/ruby")
    cmd.run_command.stdout.split
  end

  def get_nondefault_ruby2x_slots
    get_installed_ruby2x_slots.select do |slot|
      minor = slot.split('.')[1].to_i
      minor > 3 # everything above ruby 2.3 is not default
    end
  end

  def get_nondefault_ruby2x_use_flags
    slots = get_nondefault_ruby2x_slots
    slots.map { |slot| "ruby_targets_ruby#{slot.sub('.', '')}" }
  end

  def need_ruby2x_reset
    # This is how we decide if the Ruby packages need to be reset:
    # 1. Get the installed Ruby slots that are above 2.3 (e.g. 2.4, 2.5, ...)
    # 2. if the highest installed slot is above 2.3 and the desired version is below that,
    # we need to reset the Ruby packages
    slots = get_nondefault_ruby2x_slots
    return false if slots.empty? # highest installed ruby version is not a nondefault version -> everything's fine
    max_installed_minor = slots.map { |slot| slot.split('.')[1].to_i }.max
    component = node.engineyard.environment.ruby
    desired_minor = ruby_minor_version(component[:version]).to_i
    if desired_minor < max_installed_minor
      return true # we are installing a lower version than the already installed
    else
      return false # we don't change the version, or upgrade -> fine
    end
  end

  def get_nondefault_installed_ruby2x_deps
    flags = get_nondefault_ruby2x_use_flags
    flags.flat_map do |flag|
      cmd = Mixlib::ShellOut.new("equery h #{flag}")
      cmd.run_command.stdout.split.map { |pkg| "=#{pkg}" }
    end
  end

  def get_nondefault_installed_ruby2x
    cmd = Mixlib::ShellOut.new("equery l -F '=$category/$name-$version' \\>=dev-lang/ruby-2.4") # everything above Ruby 2.3
    cmd.run_command.stdout.split
  end

  def get_nondefault_ruby_packages
    get_nondefault_installed_ruby2x_deps + get_nondefault_installed_ruby2x
  end

  def remove_nondefault_ruby_packages
    packages = get_nondefault_ruby_packages
    if not packages.empty?
      execute 'remove non-default ruby packages' do
        command %Q{emerge -Cv --color n --nospinner --quiet #{packages.join(' ')}}
        action :run
      end
    end
  end

  def reset_ruby_mask
    component = node.engineyard.environment.ruby
    ruby_version = component[:version]
    ruby_mask = ruby2x_mask(ruby_version)
    use_mask_clear "ruby" do
      mask_file "ruby"
    end
    use_mask ruby_mask do
      mask_file "ruby"
      only_if { ruby_mask }
    end
  end

  def install_ruby_and_deps(reset_and_retry=true)
    if need_ruby2x_reset
      Chef::Log.info "reset the current ruby installation for a clean downgrade"
      remove_nondefault_ruby_packages
      reset_ruby_mask
    end
    component = node.engineyard.environment.ruby
    ruby_dependencies = node.default[:ruby_dependencies]
    packages = ruby_dependencies.merge({
      component[:package] => component[:version]
    })
    package_atoms = packages.map { |package_name, package_version| "=#{package_name}-#{package_version}" }
    execute 'install ruby and its dependencies' do
      command %Q{emerge --read-news=n -g -n --color n --nospinner --quiet #{package_atoms.join(' ')}}
      action :run
    end
  end

  def uninstall_rubygems_update_gems(keep_version)
    ruby_block "uninstall previous versions of rubygems" do
      block do
        output = Mixlib::ShellOut.new('gem list rubygems').run_command.stdout
        matchdata = output.match(/\(([^\)]*)\)/)
        if versions = (matchdata && matchdata[1])
          versions.split(',').each do |version|
            version.strip!
            if keep_version.nil? || (version != keep_version)
              Mixlib::ShellOut.new("gem uninstall rubygems-update -v '#{version}'").run_command
            end
          end
        end
      end
    end
  end

  def reinstall_rubygems_os_package
    ruby_dependencies = node.default[:ruby_dependencies]
    rubygems_package = 'dev-ruby/rubygems'
    rubygems_version = ruby_dependencies.fetch(rubygems_package, nil)
    if not rubygems_version.nil?
      package_atom = "=#{rubygems_package}-#{rubygems_version}"
      execute 're-install rubygems' do
        # NB: we call emerge without the -n (noreplace) flag here.
        # It would prevent re-installing a package, which is the very thing we want to achieve here.
        command %Q{emerge --read-news=n -g --color n --nospinner --quiet #{package_atom}}
        action :run
      end
    end
  end

  def ensure_rubygems_version
    rubygems = nil
    rubygems = node.engineyard.environment.ruby.fetch(:rubygems, nil) if node.engineyard.environment.ruby?
    # Specific rubygems version must be set in the ruby component, see cookbooks/ey-core/dnapi.rb.

    if rubygems && (Gem::Version.new(`gem -v`) != Gem::Version.new(rubygems))
      # Uninstall previously installed version of Rubygems
      uninstall_rubygems_update_gems(rubygems)

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
    elsif rubygems.nil?
      uninstall_rubygems_update_gems(nil)
      reinstall_rubygems_os_package
    end
  end
end

class Chef::Recipe
  include RubyHelpers
end

class Chef::Node
  include RubyHelpers
end
