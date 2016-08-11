component = node.engineyard.environment.ruby

enable_package component[:package] do
  version component[:version]
end

package component[:package] do
  version component[:version]
end


eselect component[:eselect_module] do
  slot 'ruby'
  only_if "component.has_key? :eselect_module"
end
