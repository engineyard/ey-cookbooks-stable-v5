#
# Cookbook Name:: thinking_sphinx_3
# Recipe:: install
#

if node['sphinx']['is_thinking_sphinx_instance']
  # report to dashboard
  ey_cloud_report "sphinx" do
    message "Installing sphinx"
  end

  # install package
  enable_package "app-misc/sphinx" do
    version node['sphinx']['version']
  end

  package "app-misc/sphinx" do
    version node['sphinx']['version']
    action :install
  end
end
