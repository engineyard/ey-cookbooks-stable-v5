postgres_version = node['postgresql']['short_version']

known_ebuild_versions = %w[
  9.4.8   9.4.11  9.4.12  9.4.22  9.4.24
  9.5.3   9.5.6   9.5.7   9.5.17  9.5.19
  9.6.3   9.6.13  9.6.15
  10.4    10.8    10.10
]

execute "dropping lock version file" do
  command "echo #{running_pg_version} > #{node['lock_version_file']}"
  action :run
  only_if { lock_db_version and not File.exists?(node['lock_version_file']) and pg_running }
end

execute "remove lock version file" do
  command "rm #{node['lock_version_file']}"
  only_if { not lock_db_version and File.exists?(node['lock_version_file']) }
end

enable_package "dev-libs/ossp-uuid" do
  version "1.6*"
end

ey_cloud_report "postgresql" do
  message "Handling PostgreSQL Install"
end

install_version = node['postgresql']['latest_version']
package_version = known_ebuild_versions.detect {|v| v =~ /^#{install_version}/}

# this ruby block handles if the lock version file is set
# It needs to be done like this since the file isn't present during the compile
# phase on first runs on new instances booted from snapshots
ruby_block 'check lock version' do
  block do
    if File.exists?(node['lock_version_file'])
      install_version  = %x{cat #{node['lock_version_file']}}.strip
      package_version = known_ebuild_versions.detect {|v| v =~ /^#{install_version}/}
      if package_version.nil?
        Chef::Log.info "Chef does not know about PG version #{install_version}"
        exit(1)
      end

      # do what enable_package does
      %x{ grep -q "=dev-db/postgresql-#{package_version}" /etc/portage/package.keywords/local || echo "=dev-db/postgresql-#{package_version}" >> /etc/portage/package.keywords/local}
      run_context.resource_collection.find(:package => "dev-db/postgresql").version package_version
    end
    if postgres_version_cmp(package_version, '9.3') >= 0
      %x{ grep -q "=dev-python/python-exec-0.2" /etc/portage/package.keywords/local || echo "=dev-python/python-exec-0.2" >> /etc/portage/package.keywords/local}
    end
  end
end

enable_package "dev-db/postgresql" do
  version package_version
end

package "dev-db/postgresql" do
  version package_version
  action :install
end

execute "activate_postgres" do
  command "eselect postgresql set #{postgres_version}"
  action :run
end

#NOTE: Removed for now
#execute "clean up previous version of postgresql-server-#{node['postgresql']['short_version']} " do
#  command %Q{emerge -Cv "<dev-db/postgresql-server-#{node['postgresql']['short_version']}" 2>&1 }
#  action :run
#end

# commented out till dev-perl/DBD-Pg ebuild is out with better dependencies - executing on relink recipe
# execute "clean up previous version of postgresql-base-#{node['postgresql']['short_version']} " do
#   command %Q{emerge -Cv "<dev-db/postgresql-base-#{node['postgresql']['short_version']}" 2>&1 }
#   action :run
# end
