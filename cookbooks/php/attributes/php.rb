
default['php']['full_atom'] = "dev-lang/php"

fallback_php_version = case attribute['dna']['engineyard']['environment']['components'].map(&:values).flatten.find(/^php_/).first
  when 'php_5'
    '5.6.25'
  when 'php_7'
    '7.0.6'
  else
   # '7.0.6'
   '5.6.25'	
end
 
default['php']['version'] = node.engineyard.environment.metadata('php_version', fallback_php_version)

default['php']['minor_version'] =  default['php']['version'].split(".").first(2).join(".")
