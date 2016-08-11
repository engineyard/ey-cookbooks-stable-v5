execute "cleanup_logrotate" do
  command %{ rm -f /etc/logrotate.d/*.chef-* }
  only_if %{ ls -al /etc/logrotate.d/*.chef-* }
end
