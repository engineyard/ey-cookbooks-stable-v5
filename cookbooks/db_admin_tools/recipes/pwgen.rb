pwgen_version = '2.07'

file "/etc/portage/package.unmask/pwgen" do
  content "=app-admin/pwgen-#{pwgen_version}"
  action :create
end

enable_package "app-admin/pwgen" do
  version pwgen_version
end

package "app-admin/pwgen" do
  version pwgen_version
  action :install
end
