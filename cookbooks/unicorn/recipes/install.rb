ey_cloud_report "unicorn" do
  message "processing unicorn - install"
end

gem_package 'rack' do
  version "1.6.4"
  action :install
end


gem_package 'unicorn' do
  version "4.1.1"
  action :install
end
