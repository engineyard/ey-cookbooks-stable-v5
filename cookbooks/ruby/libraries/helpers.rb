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
