define :package_use, :flags => nil, :use_file => nil do
  name = params[:name]
  flags = params[:flags]
  use_file = params[:use_file] || 'local'
  full_name = name + (" #{flags}" if flags)

  file "/etc/portage/package.use" do
    action :delete

    not_if "file -d /etc/portage/package.use"
  end

  directory "/etc/portage/package.use" do
    action :create
  end

  execute "touch /etc/portage/package.use/#{use_file}" do
    action :run
    not_if { FileTest.exists?("/etc/portage/package.use/#{use_file}") }
  end

  update_file "#{use_file} portage package.use" do
    path "/etc/portage/package.use/#{use_file}"
    body full_name
    not_if "grep '^#{full_name}$' /etc/portage/package.use/#{use_file}"
  end
end
