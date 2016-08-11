postgres_root    = '/db/postgresql'
postgres_check_bin = `( which check_postgres.pl || echo '/usr/local/bin/check_postgres.pl' ) | tr -d '\n'` 
check_postgres_version = '2.21.0'

ey_cloud_report "postgresql monitoring" do
  message "processing postgresql #{node['postgresql']['short_version']} monitoring"
end

package "dev-perl/DBD-Pg" do
  version "3.4.2"
  action :install
end

package "dev-perl/TimeDate" do
  version "2.300.0"
  action :install
end

cookbook_file "/mnt/check_postgres.tar.gz" do
  source "check_postgres.tar.gz"
  backup 0
  mode 0755
  not_if %Q{ [[ -e #{postgres_check_bin} ]] && [[ $(#{postgres_check_bin} --version |awk '{print $3}') == #{check_postgres_version} ]] }
end

execute "untar check_postgres" do
  cwd "/mnt"
  command "mkdir -p /mnt/check_postgres; tar xfv /mnt/check_postgres.tar.gz -C /mnt/check_postgres --strip-components 1"
  not_if %Q{ [[ -e #{postgres_check_bin} ]] && [[ $(#{postgres_check_bin} --version |awk '{print $3}') == #{check_postgres_version} ]] }
end

execute "make check_postgres / install" do
  cwd "/mnt/check_postgres"
  command "perl Makefile.PL && make && make install"
  not_if %Q{ [[ -e #{postgres_check_bin} ]] && [[ $(#{postgres_check_bin} --version |awk '{print $3}') == #{check_postgres_version} ]] }
end

template "/engineyard/bin/check_postgres_wrapper.sh" do
  source "check_postgres_wrapper.sh.erb"
  backup 0
  owner 'postgres'
  group 'postgres'
  mode 0751
  variables({
    :dbpass => node.engineyard.environment.ssh_password,
    :postgres_check_bin => postgres_check_bin
  })
end
