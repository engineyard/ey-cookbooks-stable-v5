default['php']['full_atom'] = "dev-lang/php"

default['php']['version'] = case attribute['dna']['engineyard']['environment']['components'].map(&:values).flatten.find(/^php_/).first
  when 'php_56'
    '5.6.30'
  when 'php_7'
    '7.0.11'
  when 'php_71'
    '7.1.0'
  when 'php_72'
    '7.2.8'
  else
   '5.6.30'
end
 
default['php']['minor_version'] =  default['php']['version'].split(".").first(2).join(".")
