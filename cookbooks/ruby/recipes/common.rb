component = node.engineyard.environment.ruby

ruby_dependencies = node.default[:ruby_dependencies]

packages = ruby_dependencies.merge({
  component[:package] => component[:version]
})
package_names = []
package_versions = []
package_atoms = []
packages.each do |package_name, package_version|
  package_names << package_name
  package_versions << package_version
  package_atoms << "=#{package_name}-#{package_version}"
end

enable_package component[:package] do
  version component[:version]
end

# TODO (jf): clean this up
# package package_names do
#   version package_versions
# end
execute 'install ruby + dependencies' do
  # shell_out_with_timeout!( "emerge -g -n --color n --nospinner --quiet#{expand_options(@new_resource.options)} #{pkg}" )
  # command %Q{emerge -Cv "<dev-db/postgresql-server-#{node['postgresql']['short_version']}" 2>&1 }
  # action :run
  command %Q{emerge -g -n --color n --nospinner --quiet #{package_atoms.join(' ')}}
  action :run
end

eselect component[:eselect_module] do
  slot 'ruby'
  only_if "component.has_key? :eselect_module"
end
