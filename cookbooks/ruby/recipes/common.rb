component = node.engineyard.environment.ruby

enable_package component[:package] do
  version component[:version]
end

install_ruby_and_deps

eselect component[:eselect_module] do
  slot 'ruby'
  only_if "component.has_key? :eselect_module"
end
