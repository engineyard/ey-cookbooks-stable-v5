# Cookbook:: newrelic
# Recipe:: default

class Chef::Recipe
  include NewrelicHelpers
end

if node.engineyard.metadata("descriptive_hostname", "false") == "true" && File.exists?('/etc/descriptive_hostname')
  descriptive_hostname = File.read('/etc/descriptive_hostname').strip
end

if newrelic_enabled?
  node.engineyard.apps.each do |app|
    ey_cloud_report "newrelic" do
      message "configuring NewRelic RPM for #{app.name}"
    end

    # Use the newrelic resource to install rpm
    newrelic "rpm" do
      app_name app.name
      app_type app.type
    end
  end

  ey_cloud_report "newrelic" do
    message "configuring NewRelic Server Monitoring"
  end

  #Update hostname
  execute "Updating hostname" do
    command "nrsysmond hostname #{descriptive_hostname}"
  end
end
