this = attribute['dna']['engineyard']['this']
instance = attribute['dna']['engineyard']['environment']['instances'].find {|instance| instance['id'] == this}

default['efs']['exists'] = instance['components'].find {|component| component['key'] == 'efs'}.flatten.include?("efs")
                
