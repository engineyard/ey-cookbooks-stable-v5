# Cookbook:: newrelic
# Recipe:: default

class Chef::Recipe
  include NewrelicHelpers
end

# Setting a meningful hostname to easy identification in New Relic dashboard
id = node.dna['engineyard']['this']
role = node.dna['instance_role'].gsub('_', ' ')
name = node['name']

descriptive_hostname = "#{id} - #{role}"
descriptive_hostname << " (#{name})" if name


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
    message "configuring NewRelic Server Monitoring for #{descriptive_hostname}"
  end

  # Use the newrelic resource to install server monitoring
  newrelic "sysmond" do
    hostname descriptive_hostname
  end

end
