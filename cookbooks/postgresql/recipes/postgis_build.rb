package_use "sci-libs/geos" do
  flags "-ruby"
end

enable_package "sci-libs/gdal" do
  version node[:gdal_version]
end

enable_package "sci-libs/geos" do
  version node[:geos_version]
end
enable_package "sci-libs/proj" do
  version node[:proj_version]
end

enable_package "dev-db/postgis" do
  version node[:postgis_version]
end

package "dev-db/postgis" do
  version node[:postgis_version]
  action :install
  timeout 1200
end
