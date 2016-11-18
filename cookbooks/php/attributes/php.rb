default['php']['full_atom'] = "dev-lang/php"

default['php']['version'] = case attribute['dna']['engineyard']['environment']['components'].map(&:values).flatten.find(/^php_/).first
  when 'php_56'
    '5.6.25'
  when 'php_70'
    '7.0.11'
  else
   #'7.0.11'
   '5.6.25'	
end
 
default['php']['minor_version'] =  default['php']['version'].split(".").first(2).join(".")
