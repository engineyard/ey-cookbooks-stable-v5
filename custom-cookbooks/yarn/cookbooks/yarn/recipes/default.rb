# frozen_string_literal: true

# Installs Yarn and sets up links properly

yarn_version = node['yarn']['version']

Chef::Log.info "Installing yarn-#{yarn_version}"

directory '/engineyard/portage/engineyard/sys-apps/yarn' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

cookbook_file "/engineyard/portage/engineyard/sys-apps/yarn/yarn-#{yarn_version}.ebuild" do
  source "yarn-generic.ebuild"
  mode '0644'
end

execute "ebuild yarn-#{yarn_version}.ebuild digest" do
  command "ebuild yarn-#{yarn_version}.ebuild digest"
  cwd '/engineyard/portage/engineyard/sys-apps/yarn/'
end

execute "rebuild metadata information for the Portage tree" do
   command "egencache --repo engineyard --update"
end

execute "update portage" do
   command "eix-update" 
end

enable_package 'sys-apps/yarn' do
  version "#{yarn_version}"
end

package 'sys-apps/yarn' do
  version "#{yarn_version}"
  action :install
end
