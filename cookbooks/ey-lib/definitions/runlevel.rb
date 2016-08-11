define :runlevel, :level => 'default' do
  case params[:action]
  when :add then
    execute "rc-update-add-#{params[:name]}" do
      action :run
      command "rc-update add #{params[:name]} #{params[:level]}"

      not_if "rc-status #{params[:level]} | grep #{params[:name]}"
    end
  when :delete then
    execute "rc-update-del-#{params[:name]}" do
      action :run
      command "rc-update del #{params[:name]}"

      only_if "rc-status #{params[:level]} | grep #{params[:name]}"
    end
  else raise param[:action]
  end
end
