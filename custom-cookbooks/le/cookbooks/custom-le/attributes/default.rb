default['le']['le_api_key'] = 'YOUR_API_KEY_HERE'

default['le']['follow_app_paths'] = []
(node['dna']['applications'] || []).each do |app_name, app_info|
#  default['le']['follow_app_paths'] << "/data/#{app_name}/shared/log/production.log"
#  default['le']['follow_app_paths'] << "/data/#{app_name}/shared/log/unicorn.log"
#  default['le']['follow_app_paths'] << "/data/#{app_name}/shared/log/delayed_job.log"
end
