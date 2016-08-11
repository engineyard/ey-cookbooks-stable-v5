ey_cloud_report "processing zsh" do
  message "processing zsh - install"
end

include_recipe "zsh::install"

enable_package node['zsh']['full_atom'] do
  version node['zsh']['version']
end

package node['zsh']['full_atom'] do
  version node['zsh']['version']
  action :install
end
