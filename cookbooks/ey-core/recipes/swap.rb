bash "make-swap-xvdc" do
  code <<-EOH
    parted -s -a optimal /dev/xvdc mklabel msdos
    parted -s -a optimal -- /dev/xvdc unit compact mkpart primary linux-swap "1" "-1"
    mkswap /dev/xvdc1
    swapon /dev/xvdc1
    echo "/dev/xvdc1 swap swap sw 0 0" >> /etc/fstab
  EOH
  only_if { File.exists?("/dev/xvdc") && !system("grep -q '/dev/xvdc1' /etc/fstab") && (`blkid /dev/xvdc1 -o value -s TYPE` !~ /^swap/) }
end

# xvda3 is provided by the AWS IaaS on m1.small and c1.medium by default
bash "use-ec2-swap-partition" do
  code <<-EOH
    swapon /dev/xvda3
    echo "/dev/xvda3 swap swap sw 0 0" >> /etc/fstab
  EOH
  only_if { File.exists?("/dev/xvda3") && %w(c1.medium m1.small).include?(node['ec2']['instance_type']) && !system("grep -q xvda3 /etc/fstab") }
end
