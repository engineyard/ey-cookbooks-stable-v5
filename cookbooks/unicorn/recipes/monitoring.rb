ey_cloud_report "unicorn" do
  message "processing unicorn - monitoring"
end

include_recipe "unicorn::monit_monitoring"
