define :report_and_run, :run => nil do
  ey_cloud_report params[:name] do
    message params[:name]
  end

  ruby_block "running #{params[:name]}" do
    block &params[:run]
  end
end
