#prechef_command = metadata_any_get("prechef_command")
prechef_command = node.engineyard.metadata("prechef_command")

if prechef_command
  Chef::Log.info "Prechef command detected"

  prechef_command_account = metadata_account_get("prechef_command") 
  if prechef_command_account
    Chef::Log.info "Prechef command Account [#{prechef_command_account}]"

    ey_cloud_report "prechef" do
      message 'Account command found and running...'
    end

    bash 'Prechef command Account Level' do
      code prechef_command_account
    end        
  end
  
  prechef_command_env = metadata_env_get("prechef_command")
  if prechef_command_env
    Chef::Log.info "Prechef command Env [#{prechef_command_env}]"

    ey_cloud_report "prechef" do
      message 'Environment command found and running...'
    end

    bash 'Prechef command Env Level' do
      code prechef_command_env
    end        
  end
    
  prechef_command_app = metadata_any_app_get("prechef_command")
  if prechef_command_app
    Chef::Log.info "Prechef command App [#{prechef_command_app}]"

    ey_cloud_report "prechef" do
      message 'Application command found and running...'
    end

    bash 'Prechef command App Level' do
      code prechef_command_app
    end        
  end

end
