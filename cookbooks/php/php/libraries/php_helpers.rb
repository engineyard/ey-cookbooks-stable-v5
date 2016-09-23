module PhpHelpers
  def check_fpm_log_owner(app_name)
    # If fpm was previously run under root, we need to change ownership of the
    # slowlog for php-fpm to start under the "deploy" user
    directory "/var/log/engineyard/apps/#{app_name}" do
      owner node["owner_name"]
      group node["owner_name"]
      mode "0755"
      action :create
      recursive true
    end

    file "/var/log/engineyard/apps/#{app_name}/php-fpm.slow.log" do
      owner node["owner_name"]
      group node["owner_name"]
      mode "0600"
      action :create
    end
  end

  def restart_fpm
    # Ensure PHP is reloaded and not running under Root
    # Sample Process line
    # deploy   31796  0.0  0.2 113412  4900 ?        Ss   21:36   0:00 php-fpm: master process (/etc/php-fpm.conf)

    current_php_process = `ps auwx |grep "[p]hp-fpm: master process"`.split(' ')
    current_php_owner = current_php_process[0]
    current_php_pid = current_php_process[1].to_i

    if current_php_owner == "root"
      if current_php_pid > 0
        ey_cloud_report "PHP" do
          message "Restart of php-fpm PID #{current_php_pid}"
        end

        Process.kill("SIGTERM", current_php_pid) unless current_php_pid == 0
        # Monit will restart the process under user
      end
    else
      if current_php_pid > 0
        ey_cloud_report "PHP" do
          message "Graceful restart of php-fpm PID #{current_php_pid}"
        end

        Process.kill("SIGUSR2", current_php_pid)
        # Signal graceful restart
      else
        ey_cloud_report "PHP" do
          message "php-fpm process not started yet"
        end
      end
    end
  end
end
