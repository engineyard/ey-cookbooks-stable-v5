component = node.engineyard.environment.ruby
ruby_version = component[:version]

ruby_mask = ruby2x_mask(ruby_version)
ruby_dependencies = node.default[:ruby_dependencies]
do_upgrade_eselect_ruby = node.default[:do_upgrade_eselect_ruby]

unmask_package component[:package] do
  version component[:version]
  unmaskfile "ruby"
end

use_mask ruby_mask do
  mask_file "ruby"
  only_if "ruby_mask"
end

package "app-eselect/eselect-ruby" do
  action :upgrade
  only_if { do_upgrade_eselect_ruby }
end

ruby_dependencies.each do |dep, dep_version|
  enable_package dep do
    version dep_version
  end
end

include_recipe 'ruby::common'

# TODO (jf): remove this, not relevant on stable-v5 (Verify!!!!)
execute "install-modern-rack" do
  command "gem install rack -v 1.0.1"
  only_if { component[:full_version] =~ /^ruby-1\.8\.6/ }
end
