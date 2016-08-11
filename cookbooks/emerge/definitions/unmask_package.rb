define :unmask_package, :unmaskfile => nil, :version => nil do
  name = params[:name]
  version = params[:version]
  unmaskfile = params[:unmaskfile]
  full_name = "=" + name + '-' + version

  file "/etc/portage/package.unmask" do
    action :delete

    not_if "file -d /etc/portage/package.unmask"
  end

  directory "/etc/portage/package.unmask" do
    action :create
  end

  execute "touch /etc/portage/package.unmask/#{unmaskfile}" do
    action :run
    not_if { FileTest.exists?("/etc/portage/package.unmask/#{unmaskfile}") }
  end

  update_file "local portage package.use" do
    path "/etc/portage/package.unmask/#{unmaskfile}"
    body full_name
    not_if "grep '#{full_name}' /etc/portage/package.unmask/#{unmaskfile}"
  end
end
