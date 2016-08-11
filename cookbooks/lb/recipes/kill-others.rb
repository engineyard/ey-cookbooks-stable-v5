# Restart nginx if it's running before us.
# This is to try to ensure our ports aren't in use.

# FIXME This is kind of a hack and assumes knowledge of recipe execution order

execute "restart-nginx-if-necessary" do
  command "/etc/init.d/nginx restart"
  only_if "lsof -n -i :80 -i :443 | grep LISTEN | grep nginx"
end
