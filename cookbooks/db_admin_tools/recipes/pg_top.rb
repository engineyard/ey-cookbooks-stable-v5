pg_top_version = '3.7.0'

file "/etc/portage/package.unmask/pg_top" do
  content "=dev-db/pg_top-#{pg_top_version}"
  action :create
end

enable_package "dev-db/pg_top" do
  version pg_top_version
end

package "dev-db/pg_top" do
  version pg_top_version
  action :install
end
