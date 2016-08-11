# This is made as a definition simply because there are two places where it might be run when setting up a slave.
# It won't be run in both places but Chef sees them both and won't run it in the second place if this is set
# up as a recipe

define :handle_mysql_d do
  ruby_block "set up mysql.d custom config dir" do
    block do
      system('mkdir -p /db/mysql.d; chown mysql:mysql /db/mysql.d')
      system('[[ -n "$(ls /etc/mysql.d)" ]] && mv /etc/mysql.d/* /db/mysql.d/')
      system("mount --bind /db/mysql.d /etc/mysql.d")
      system("echo '/db/mysql.d /etc/mysql.d none bind' >> /etc/fstab")
    end

    not_if "grep -qs '/etc/mysql.d' /etc/fstab"
  end
end