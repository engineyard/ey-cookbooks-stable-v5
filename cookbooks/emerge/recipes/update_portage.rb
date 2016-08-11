portage_version = node.engineyard.metadata("portage_version","2.2.28")

Chef::Log.info "Portage Version Desired: #{portage_version}"

if !Dir.exist?("/var/db/pkg/sys-apps/portage-#{portage_version}")
  Chef::Log.info "Not installed - Will update portage"
  
  enable_package 'sys-apps/portage' do
    version portage_version
  end

  package 'sys-apps/portage' do
    version portage_version
    action :install
  end
end
