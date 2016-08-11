define :directory_after_deploy, :action => :create do
  resource = directory(params[:name]) do
    action :nothing
  end

  node.dna['_after_deploy_resources'] ||= {}
  node.normal['_after_deploy_resources'][resource] = params[:action]
end
