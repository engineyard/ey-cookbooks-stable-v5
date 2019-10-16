toolkit_version = '2.2.20'

unmask_package "dev-db/percona-toolkit" do
  version toolkit_version
  unmaskfile "percona-toolkit"
end

enable_package "dev-db/percona-toolkit" do
  version toolkit_version
end

package "dev-db/percona-toolkit" do
  version toolkit_version
  action :install
end
