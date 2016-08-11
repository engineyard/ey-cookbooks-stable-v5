class Chef
  class Recipe
    def monitrc(name, variables={})
      Chef::Log.info("Making monitrc for: #{name}")
      managed_template "/etc/monit.d/#{name}#{variables[:app_name] ? '.'+variables[:app_name] : ''}.monitrc" do
        owner "root"
        group "root"
        mode 0644
        source "#{name}.monitrc.erb"
        variables variables
        notifies :run, 'execute[restart-monit]', :immediate
        action :create
      end
    end
  end
end  
