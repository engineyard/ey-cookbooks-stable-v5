default['env_vars'].tap do |e|

  # If you want to restart the application during the chef run, set this to true
  #
  # NOTE: This will restart your application on ALL app instances at the same time
  #
  # A better way is schedule a maintenance window,
  # during which you will iterate through all the application instances and run:
  # /engineyard/bin/app_<application_name> restart
  #
  e['perform_restart'] = false
end
