ey_cloud_report "unicorn" do
  message "processing unicorn - install"
end

gem_package 'unicorn' do
  version "4.1.1"
  action :install
end
