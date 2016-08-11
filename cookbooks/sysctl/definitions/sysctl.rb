define :sysctl, :action => :add do
  case params[:action]
  when :add
    params[:variables].each do |name, value|
      search  = "^#{Regexp.escape(name)}\\s*=.*$"
      protect_grep = "grep -E -B 1 '^#{Regexp.escape(name)}' /etc/sysctl.conf | grep -Eq '^# *protect-from-chef *#{Regexp.escape(name)}'"

      execute "remove-#{name}-in-sysctl" do
        command "sed -i '/#{search}/d' /etc/sysctl.conf"
        not_if protect_grep
      end

      update_file "add-#{name}-to-sysctl" do
        action :append
        path '/etc/sysctl.conf'
        body "#{name} = #{value}"
        not_if protect_grep
      end
    end

    execute "reload-sysctl" do
      command "sysctl -p"
    end
  end
end
