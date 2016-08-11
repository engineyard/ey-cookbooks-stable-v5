enable_package "dev-vcs/git" do
  version node.dna['git']['version']
end

package "dev-vcs/git" do
  version node.dna['git']['version']
  action :install
end
