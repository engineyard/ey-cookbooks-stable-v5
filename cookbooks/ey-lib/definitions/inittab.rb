define :inittab, :runlevel => [3, 4, 5], :action => "respawn", :backup => 5 do
  valid_actions = %w( respawn wait once boot bootwait off ondemand initdefault sysinit powerwait powerfail powerokwait powerfailnow ctrlaltdel kbrequest )

  if params[:action].eql?("delete")
    execute "delete-#{params[:name]}-inittab-entry" do
      command "sed -i 's/^#{params[:name]}:.*//' /etc/inittab"
      only_if "grep -q '^#{params[:name]}:' /etc/inittab"
    end
  else
    raise "Invalid inittab action '#{params[:action]}'" unless valid_actions.include?(params[:action].to_s)
    raise "Inittab command missing" if params[:command].nil?
    raise "Inittab action name too long" if params[:name].length > 4

    runlevel = [*params[:runlevel]].join
    initcommand = params[:command]
    initstring = [params[:name], runlevel, params[:action], initcommand].join(":")
    timestamp = Time.now.strftime("%Y-%m-%d-%I-%M-%S")
    backup_path = "/tmp/inittab.#{$$}.tmp"

    execute "cleanup-backup-inittab" do
      action :nothing

      command <<-SH
        ls -r1 /etc/inittab.* |tail -n+#{params[:backup] + 1} | xargs rm -f
      SH
    end

    execute "rotate-backup-inittab" do
      action :nothing

      command <<-SH
        [[ -f #{backup_path} && ! `diff -q /etc/inittab #{backup_path} &> /dev/null` ]] && mv #{backup_path} /etc/inittab.#{timestamp}
        /bin/true
      SH

    end

    execute "start-backup-inittab" do
      command "cp /etc/inittab /tmp/inittab.#{$$}.tmp"

      not_if { params[:backup] == 0 || File.exists?(backup_path) }

      notifies :run, resources(:execute => "cleanup-backup-inittab"), :delayed
      notifies :run, resources(:execute => "rotate-backup-inittab"), :delayed
    end

    execute "remove-#{params[:name]}-from-inittab" do
      command "sed -i '/^#{params[:name]}:.*/d' /etc/inittab"
    end

    update_file "add-#{params[:name]}-to-inittab" do
      path '/etc/inittab'
      body initstring
    end

    execute "telinit-q" do
      command "telinit q"
    end

  end
end
