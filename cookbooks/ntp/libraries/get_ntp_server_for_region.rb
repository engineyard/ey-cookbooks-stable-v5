class Chef
  class Recipe
    def get_ntp_server_for_region
      # http://www.pool.ntp.org/zone/
      case node.engineyard.environment['region']
      when /^eu-/
        ['0.europe.pool.ntp.org','1.europe.pool.ntp.org','2.europe.pool.ntp.org']
      when /^us-/
        ['0.north-america.pool.ntp.org','1.north-america.pool.ntp.org','2.north-america.pool.ntp.org']
      when /^ap-/
        ['0.asia.pool.ntp.org', '1.asia.pool.ntp.org','2.asia.pool.ntp.org']
      else
        ['0.pool.ntp.org','1.pool.ntp.org','2.pool.ntp.org']
      end
    end
  end
end