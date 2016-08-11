if node.engineyard.environment.component?('nodejs')
  # Use this recipe to load the Node version we use to run the Node applications.
  # Node is loaded in /usr so we make sure the user always uses the version that we support.
  include_recipe 'node::component'
else
  # node is installed in /opt, and eselect'able
  # a default known good version of node (for use w/ Rails asset pipeline)
  # will always be installed
  include_recipe 'node::common'
end
