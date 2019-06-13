define :use_mask_clear do
  mask_file = params[:mask_file]

  file "/etc/portage/profile/use.mask/#{mask_file}" do
    action :delete

    only_if { FileTest.exists?("/etc/portage/profile/use.mask/#{mask_file}") }
  end
end
