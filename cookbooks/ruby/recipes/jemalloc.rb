component = node.engineyard.environment.ruby
ruby_jemalloc_available = node.default[:ruby_jemalloc_available]

ruby_pkg_name = component[:package].split('/')[1]

pkg_download_url = "http://distfiles.engineyard.com/EYGL2016.06-#{ruby_pkg_name}-#{component[:version]}-jemalloc.tbz2"
pkg_destination_directory = "/engineyard/portage/packages/dev-lang"
pkg_destination_filename = "#{ruby_pkg_name}-#{component[:version]}.tbz2"
pkg_destination_path = File.join(pkg_destination_directory, pkg_destination_filename)

# Check all apps on the env for ruby+jemalloc
# If all of them have it enabled, then activate jemalloc
ruby_jemalloc_enabled = node['dna']['engineyard']['environment']['apps'].all? do |app_data|
  is_ruby_jemalloc_enabled(app_data)
end

if ruby_jemalloc_available and ruby_jemalloc_enabled
  package_use ruby_package_atom(component[:package], component[:version]) do
    flags 'jemalloc'
    use_file 'ruby-jemalloc'
  end
  
  directory "create the #{ruby_pkg_name} binary directory" do
    path pkg_destination_directory
    recursive true
    action :create
  end

  ruby_block "download the #{ruby_pkg_name} binary package" do
    block do
      wget_cmd = Mixlib::ShellOut.new(
        "wget -O #{pkg_destination_path} #{pkg_download_url}"
      )
      wget_cmd.run_command
      if wget_cmd.error?
        Chef::Log.info "The #{pkg_destination_filename} (with jemalloc) binary package does not exist."
        Chef::Log.info wget_cmd.stderr
        Mixlib::ShellOut.new("rm -f #{pkg_destination_path}").run_command
      else # successfully downloaded
        Mixlib::ShellOut.new("emaint --fix binhost && eix-update").run_command
      end
    end
  end
else
  package_use_clear 'remove jemalloc USE-flag' do
    use_file 'ruby-jemalloc'
  end

  bash 'remove the binary packages' do
    code <<-EOH
    rm -f #{File.join(pkg_destination_directory, "#{ruby_pkg_name}-*.tbz2")}
    emaint --fix binhost
    eix-update
    EOH
    action :run
  end
end

