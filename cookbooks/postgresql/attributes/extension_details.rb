# Here you can set a few key attributes for individual extensions. Each key
# has a default so an extension entry is only needed if one or more of the 
# defaults need to be overriden.
#
# Valid keys w/ their defualts:
#
# min_pg_version: 9.4 - minimum Postgres version needed
# max_pg_version: nil
# use_load: nil -- this is mostly for auto_explain which needs LOAD
#    statement instead of CREATE EXTENSION

default[:pg_extensions_file] = '/db/postgresql/extensions.json'

default[:pg_ext_details] = {
  'auto_explain' => {
    use_load: true
  },
  'test_parser' => {
    max_version: 9.4
  },
  'test_shm_mq' => {
    max_version: 9.4
  }
}

# postgis version details
case attribute.dna.engineyard.environment.db_stack_name
when "postgres9_6"
  default[:postgis_version] = "2.3.3"
  # separating these in case we decide to bump them later
  default[:proj_version] = "4.8.0"
  default[:geos_version] = "3.5.0-r2"
  default[:gdal_version] = "1.11.1"
when "postgres10"
  default[:postgis_version] = "2.4.4"
  default[:proj_version] = "4.8.0"
  default[:geos_version] = "3.6.2"
  default[:gdal_version] = "1.11.1-r3"
else
  default[:postgis_version] = "2.2.2"
  default[:proj_version] = "4.8.0"
  default[:geos_version] = "3.5.0-r2"
  default[:gdal_version] = "1.11.1"
end
