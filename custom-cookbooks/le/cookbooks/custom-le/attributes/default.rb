#LE API KEY SHOULD BE SET HERE, IT CAN BE FOUND IN THE EY ADD-ONS PORTOL
default['le']['le_api_key'] = 'YOUR_API_KEY_HERE'

#SYSTEM LOGS TO FOLLOW SHOULD BE DEFINED HERE
default['le']['follow_paths'] = [
  "/var/log/syslog",
  "/var/log/auth.log",
  "/var/log/daemon.log"
]

#NGINX LOGS TO FOLLOW SHOULD BE DEFINED HERE
(node['dna']['applications'] || []).each do |app_name, app_info|
  default['le']['follow_paths'] << "/var/log/nginx/#{app_name}.access.log"
#  default['le']['follow_paths'] << "/var/log/nginx/#{app_name}.error.log"
#  default['le']['follow_paths'] << "/var/log/nginx/#{app_name}.access.ssl.log"
#  default['le']['follow_paths'] << "/var/log/nginx/#{app_name}.error.ssl.log"
end

#APPLICATION LEVEL LOGS TO FOLLOW SHOULD BE DEFINED HERE
framework = node['dna']['environment']['framework_env']
default['le']['follow_app_paths'] = []
(node['dna']['applications'] || []).each do |app_name, app_info|
  default['le']['follow_app_paths'] << "/data/#{app_name}/shared/log/#{framework}.log"
#  default['le']['follow_app_paths'] << "/data/#{app_name}/shared/log/unicorn.log"
#  default['le']['follow_app_paths'] << "/data/#{app_name}/shared/log/passenger.8000.log"
#  default['le']['follow_app_paths'] << "/data/#{app_name}/shared/log/delayed_job.log"
end
