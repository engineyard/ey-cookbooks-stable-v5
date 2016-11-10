ey_cloud_report "unicorn" do
  message "processing unicorn - install"
end

gem_package 'rack' do
  version "1.6.4"
  action :install
  only_if { node['dna']['ruby_version'].split(' ').last.split('.')[0,1].join.to_i < 22 }
end


gem_package 'unicorn' do
  version "4.1.1"
  action :install
end
