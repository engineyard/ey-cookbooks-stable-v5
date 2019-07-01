define :package_use_clear do
  use_file = params[:use_file]

  file "/etc/portage/package.use/#{use_file}" do
    action :delete

    only_if { FileTest.exists?("/etc/portage/package.use/#{use_file}") }
  end
end
