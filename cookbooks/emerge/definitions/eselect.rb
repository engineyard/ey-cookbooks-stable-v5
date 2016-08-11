define :eselect do
  slot = params[:slot]

  execute "eselect-#{params[:name]}-for-#{slot}" do
    command "eselect #{slot} set #{params[:name]} && env-update && source /etc/profile"
  end
end
