# Remove gems that were installed on the system ruby in previous chef runs.
# They are now installed in the ey_resin isolated ruby.
gem_package "ey-flex" do
  action :remove
end

gem_package "ey_enzyme" do
  action :remove
end

gem_package "ey_cloud_server" do
  action :remove
end

gem_package "chef" do
  action :remove
end

gem_package "chef-deploy" do
  action :remove
end

## Rack 0.4.0 is on the AMI and breaks newer versions of passenger.
gem_package "rack" do
  version "0.4.0"
  action :remove
end
