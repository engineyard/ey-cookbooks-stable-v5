# Report to Cloud dashboard
ey_cloud_report "processing php composer.rb" do
  message "processing php - composer"
end

# Download newrelic PHP at specified version
remote_file "/tmp/composer_install.php" do
  source "https://getcomposer.org/installer"
end

bash "install_phpcomposer" do
  user 'root'
  code <<-EOH
mkdir /usr/lib/php_composer
php -d allow_url_fopen=On /tmp/composer_install.php -- --install-dir=/usr/lib/php_composer
chown -R #{node["owner_name"]}:#{node["owner_name"]} /usr/lib/php_composer
chmod -R 755 /usr/lib/php_composer
  EOH
  action :run
end

cookbook_file "/usr/bin/composer" do
  owner node["owner_name"]
  group node["owner_name"]
  mode 0755
  source "composer.sh"
  backup 0
end
