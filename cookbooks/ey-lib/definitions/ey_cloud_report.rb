define :ey_cloud_report do
  ruby_block "reporting for #{params[:name]}" do
    block do
      Chef::Log.info params[:message]
    end
  end

  #TODO: turn this back on?
  # execute "reporting for #{params[:name]}" do
  #   command "ey-enzyme --report '#{params[:message]}'"
  #   epic_fail false
  # end
end
