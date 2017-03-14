# Report to Cloud dashboard
ey_cloud_report "processing elixir" do
  message "processing elixir - install"
end

# Unmask the erlang package
enable_package node['elixir']['erlang']['full_atom'] do
  version node['elixir']['erlang']['version']
end


# Unmask the elixir package
enable_package node['elixir']['full_atom'] do
  version node['elixir']['version']
end

# Install erlang
package node['elixir']['erlang']['full_atom'] do
  version node['elixir']['erlang']['version']
  action :install
end

#Install elixir
package node['elixir']['full_atom'] do
  version node['elixir']['version']
  action :install
end

#Install rebar
execute "install rebar" do
  command "su - -c 'mix local.rebar --force' #{node.engineyard.environment.ssh_username}"
end

#Install hex
execute "install hex" do
  command "su - -c 'mix local.hex --force' #{node.engineyard.environment.ssh_username}"
end
