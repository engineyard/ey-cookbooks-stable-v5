resin_path = "/usr/local/ey_resin/ruby/bin"
gem_bin_path = "/usr/local/ey_resin/bin"
bin_path = '/usr/local/bin'

["eybackup", "ey-snapshots", "ey-snaplock"].each do |executable|
  link "#{bin_path}/#{executable}" do
    to "#{gem_bin_path}/#{executable}"
    only_if { File.exists?("#{gem_bin_path}/#{executable}") }
  end
end
