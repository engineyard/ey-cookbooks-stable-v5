# Installs Yarn and sets up links properly
# TODO:  create a 'custom-yarn' recipe where customer can specify the version

yarn_version = node['yarn']['version']

directory "/engineyard/portage/engineyard/sys-apps/yarn" do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
end

cookbook_file "/engineyard/portage/engineyard/sys-apps/yarn/yarn-#{yarn_version}.ebuild" do
  source "yarn-#{yarn_version}.ebuild"
  mode "0644"
end

execute "ebuild yarn-#{yarn_version}.ebuild digest" do
  command "ebuild yarn-#{yarn_version}.ebuild digest"
  cwd "/engineyard/portage/engineyard/sys-apps/yarn/"
end

enable_package 'sys-apps/yarn' do
  version "#{yarn_version}"
end

package 'sys-apps/yarn' do
  version "#{yarn_version}"
  action :install
end


