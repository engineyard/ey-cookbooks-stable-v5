this = attribute['dna']['engineyard']['this']
instance = attribute['dna']['engineyard']['environment']['instances'].find {|instance| instance['id'] == this}

default['efs']['exists'] = instance['components'].flat_map(&:values).include?("efs")
default['efs']['mountpoint'] = '/efs'
default['efs']['sharedfolder'] = '/shared'
