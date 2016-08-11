define :backup_cron, :action => :create do
  cron params[:name] do
    action params[:action]

    minute   params[:minute]
    hour     params[:hour]
    day      params[:day]
    month    params[:month]
    weekday  params[:weekday]
    command  params[:command]
  end
end
