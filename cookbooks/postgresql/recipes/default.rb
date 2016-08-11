postgres_version = node['postgresql']['short_version']

if ['solo', 'db_master', 'db_slave'].include?(node.dna['instance_role'])
  ey_cloud_report "start postgresql run" do
    message "processing postgresql #{postgres_version}"
  end
  include_recipe "ebs::default"
  include_recipe "postgresql::client_config"
  include_recipe "postgresql::server_install"
  include_recipe "postgresql::server_configure"
  include_recipe 'ey-backup::postgres'
  include_recipe "postgresql::monitoring"
  include_recipe "postgresql::relink_postgresql"
  ey_cloud_report "stop postgresql run" do
    message "processing postgresql #{postgres_version} finished"
  end
end
if ['app_master', 'app', 'util'].include?(node.dna['instance_role'])
  ey_cloud_report "start postgresql run" do
    message "processing postgresql #{postgres_version}"
  end
  include_recipe "postgresql::client_config"
  include_recipe "postgresql::server_install"
  include_recipe "postgresql::relink_postgresql"
  ey_cloud_report "stop postgresql run" do
    message "processing postgresql #{postgres_version} finished"
  end
end
