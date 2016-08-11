resin_path = "/usr/local/ey_resin/ruby/bin"
gem_bin_path = "/usr/local/ey_resin/bin"
bin_path = '/usr/local/bin'

gem_name = 'ey_cloud_server'
version = '1.4.51'

execute "installing #{gem_name} - #{version}" do
  command "#{resin_path}/gem install #{gem_name} -v #{version} --no-ri --no-rdoc"
  not_if "#{resin_path}/gem list #{gem_name} |grep #{version}"
end

["eybackup", "ey-snapshots", "ey-snaplock"].each do |executable|
  link "#{bin_path}/#{executable}" do
    to "#{gem_bin_path}/#{executable}"
    only_if { File.exists?("#{gem_bin_path}/#{executable}") }
  end
end
