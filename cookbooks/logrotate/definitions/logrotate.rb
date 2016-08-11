define :logrotate, :frequency => "daily", :rotate_count => 30, :rotate_if_empty => false,
       :missing_ok => true, :compress => true, :enable => true, :date_ext => true,
       :extension => 'gz', :copy_then_truncate => false, :delay_compress => false do
  template "/etc/logrotate.d/#{params[:name]}" do
    action params[:enable] ? :create : :delete
    cookbook "logrotate"
    source "logrotate.conf.erb"
    variables(:p => params)
    backup false
    owner "root"
    group "root"
    mode 0644
  end
end
