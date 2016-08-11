class Chef
  class Recipe
    # Returns list of locations to find logs
    # for the chosen database
    # Returns [] if no database was chosen
    def db_log_paths
      db_type, db_version = db_type_and_version
      if db_type == "postgres"
        ["/db/postgresql/#{db_version}/data/pg_log/*"]
      elsif db_type == "mysql"
        if db_version == "5.0"
          ["/db/mysql/log/mysqld.err"]
        else
          ["/db/mysql/#{db_version}/log/mysqld.err"]
        end
      else
        []
      end
    end
  end
end
