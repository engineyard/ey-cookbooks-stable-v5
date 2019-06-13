component = node.engineyard.environment.ruby

# ruby_dependencies = node.default[:ruby_dependencies]
# packages = ruby_dependencies.merge({
#   component[:package] => component[:version]
# })
# package_atoms = packages.map { |package_name, package_version| "=#{package_name}-#{package_version}" }

enable_package component[:package] do
  version component[:version]
end

# TODO (jf): this will now be done in a library method (install_ruby_and_deps)
# execute 'install ruby and its dependencies' do
#   command %Q{emerge --read-news=n -g -n --color n --nospinner --quiet #{package_atoms.join(' ')}}
#   action :run
# end
install_ruby_and_deps

eselect component[:eselect_module] do
  slot 'ruby'
  only_if "component.has_key? :eselect_module"
end
