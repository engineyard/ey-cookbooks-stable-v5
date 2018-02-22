# Cookbook:: newrelic
# Recipe:: default

class Chef::Recipe
  include NewrelicHelpers
end

# Setting a meningful hostname to easy identification in New Relic dashboard
id = node['dna']['engineyard']['this']
role = node['dna']['instance_role'].gsub('_', ' ')
name = node['dna']['name']
environment = node['dna']['environment']['name']

descriptive_hostname = "#{id} - #{role}"
descriptive_hostname << " (#{name})" if name

labels = "Server:#{id};Role:#{role};Environment:#{environment}"


if newrelic_enabled?
  # do not install newrelic rpm on db instances
  if ['app_master', 'app', 'solo', 'util'].include?(node['dna']['instance_role'])
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
  end

  ey_cloud_report "newrelic" do
    message "configuring NewRelic Server Monitoring for #{descriptive_hostname}"
  end

  # Use the newrelic resource to install server monitoring
  newrelic "sysmond" do
    hostname descriptive_hostname
    labels labels
  end

end
