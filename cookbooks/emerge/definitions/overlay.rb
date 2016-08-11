define :overlay, :portage_path => '/engineyard/portage/engineyard', :files => [] do

  portage_path = params[:portage_path]
  ebuild_name  = params[:name]
  ebuild_file  = params[:ebuild]
  ebuild_dir   = File.join(portage_path, ebuild_name)
  files_dir    = File.join(portage_path, ebuild_name, 'files')
  ebuild_path  = File.join(portage_path, ebuild_name, ebuild_file)

  directory ebuild_dir do
    owner 'root'
    group 'root'
    mode 0755
    recursive true
  end

  directory files_dir do
    owner 'root'
    group 'root'
    mode  0755
    recursive true
  end

  remote_file ebuild_path do
    source ebuild_file
    owner 'root'
    group 'root'
    mode 0644
  end

  params[:files].each do |file|

    dirname = file.gsub(File.basename(file), '')
    directory "#{files_dir}/#{dirname}" do
      owner 'root'
      group 'root'
      mode  0755
      recursive true
      not_if { File.basename(file) == file }
    end

    remote_file File.join(files_dir, file) do
      source file
      owner 'root'
      group 'root'
      mode 0644
    end
  end

  execute "rebuild-#{ebuild_name}-manifest" do
    command "cd #{ebuild_dir} && ebuild #{ebuild_file} digest"
  end
end
