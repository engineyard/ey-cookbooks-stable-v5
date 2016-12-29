image = "crigor/todo3"
tag = "latest"

docker_image image do
  tag tag
  action :pull 
end

docker_container "todo" do
  repo "crigor/todo"
  tag "latest"
  port "3000:3000"
  volume ["/data/docker_apps/todo_rails/config/database.yml:/usr/src/app/config/database.yml"]
  restart_policy "always"
  action :run
end  

execute "redeploy #{image}" do
  notifies :redeploy, "docker_container[#{image}]", :immediately
  action :run
  only_if {Docker::Container.get("todo").info["Image"] != Docker::Image.get(image).id}
end
