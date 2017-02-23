# The following generates /etc/logrotate.d/example
logrotate "example" do

  # Required Setting:
  files "/path/to/logfiles/*log"

  # Optional Settings:
  # See `man logrotate` in the server for more details.

  # Default: "daily"
  # Syntax:
  # frequency "daily"

  # Default: 30
  # Syntax:
  # rotate_count 15

  # Default: false
  # Syntax:
  # rotate_if_empty true

  # Default: true
  # Syntax:
  # missing_ok false

  # Default: true
  # Syntax:
  # compress false

  # Default: true
  # Description: `true` creates config file, `false` deletes it
  # Syntax:
  # enable false

  # Default: true
  # Syntax:
  # date_ext false

  # Default: 'gz'
  # Syntax:
  # extension 'log'

  # Default: false
  # Syntax:
  # copy_then_truncate true

  # Default: false
  # Syntax:
  # delay_compress true
end
