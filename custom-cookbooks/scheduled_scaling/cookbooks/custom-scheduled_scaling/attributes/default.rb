
default['scheduled_scaling'].tap do |scheduled_scaling|

  # The account name
  # Substite 'my_account' for the correct account name
  scheduled_scaling['account'] = "my_account"

  # Run the scaling on a named util instance
  # This is the default
  # scheduled_scaling['is_scheduler_instance'] = (
  #   node['dna']['instance_role'] == 'util' &&
  #   node['dna']['name'] == 'scaler')

  # Example for running the scaling from an app_master
  # scheduled_scaling['is_scheduler_instance'] = (
  #   node['dna']['instance_role'] == 'app_master')
  # Run the scaling on a solo instance
  # Useful only if it scaling another environment
  #scheduled_scaling['is_scheduler_instance'] = (node['dna']['instance_role'] == 'solo')

  # Scheduling tasks, specified as cronjobs
  # Add them here
  #scheduled_scaling[:tasks] = []
  # replace 'my_environment' for the name of the env to be stopped/started
  # replace 'my_environment_blueprint' for the name of the blueprint to be used when starting the environment
  # replace 'x.x.x.x' for the Elastic IP to be attached when starting the environment
  # Example:
  # scheduled_scaling[:tasks] = [{:name => "stop_env", :time => "0 6/4 * * *", :type => "stop_environment", :environment_name => "my_environment", :timeout => "1200"},
  #                              {:name => "start_env", :time => "0 */4 * * *", :type => "start_environment", :environment_name => "my_environment", :timeout => "5200", :blueprint_name => "my_environment_blueprint", :ip_address => "x.x.x.x"}]

 end


