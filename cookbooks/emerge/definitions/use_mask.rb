define :use_mask, :mask_file => nil do
  name = params[:name]
  mask_file = params[:mask_file]

  file "/etc/portage/profile/use.mask" do
    action :delete

    not_if "file -d /etc/portage/profile/use.mask"
  end

  directory "/etc/portage/profile/use.mask" do
    action :create
  end

  execute "touch /etc/portage/profile/use.mask/#{mask_file}" do
    action :run
    not_if { FileTest.exists?("/etc/portage/profile/use.mask/#{mask_file}") }
  end

  update_file "local portage package.use" do
    path "/etc/portage/profile/use.mask/#{mask_file}"
    body name
    not_if "grep '#{name}' /etc/portage/profile/use.mask/#{mask_file}"
  end
end
