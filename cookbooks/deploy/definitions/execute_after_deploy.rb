define :execute_after_deploy, :action => :run, :command => nil do
  resource = execute(params[:name]) do
    command params[:command]
    action :nothing
  end

  node['dna']['_after_deploy_resources'] ||= {}
  node.normal['_after_deploy_resources'][resource] = params[:action]
end
