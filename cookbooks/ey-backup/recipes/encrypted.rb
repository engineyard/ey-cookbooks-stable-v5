ey_cloud_report "ey_backup" do
  message "processing encrypted database backups"
end

package "app-crypt/gnupg" do
  version '2.0.28'
  action :nothing
end.run_action(:install)


node.engineyard.environment['apps'].each do |app|
  app['components'].each do |component|
    if component['key'] == 'encrypted_backup'
      execute "echo \"#{component['public_key']}\" > /root/backup_pgp_key" do
        action :nothing
      end.run_action(:run)

      execute "import gpg key for #{app['name']}-#{component['key']}" do
        command "gpg --import /root/backup_pgp_key"
        action :nothing
        not_if {component['public_key'].empty?}
      end.run_action(:run)

    end
  end
end
