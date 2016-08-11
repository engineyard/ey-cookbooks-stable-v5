#Update Timezone data
enable_package "sys-libs/timezone-data" do
  version node['timezones']['version']
end

package "sys-libs/timezone-data" do
  version node['timezones']['version']
  action :upgrade
end
