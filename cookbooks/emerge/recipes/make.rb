# Please don't change things here without talking to the distro team.

# CC-168 - only update on old ami
if File.exists?("/etc/engineyard/release") then
  AMI_Release = IO.readlines("/etc/engineyard/release")
  case AMI_Release.first
  when /^2009a.1_pre51/i  # Checking entire string as any other AMI we need to assume it's good
    # oldami and newami (pre-2012) need make.conf updated
    case node['dna']['kernel']['machine']
    when 'x86_64'
      template "/etc/make.conf" do
        source "make.conf.erb"
        owner "root"
        group "root"
        variables :cflags => 'athlon64',
        :chost            => 'x86_64',
        :binhost          => 'amd64'
      end
    when 'i686'
      template "/etc/make.conf" do
        source "make.conf.erb"
        owner "root"
        group "root"
        variables :cflags => 'pentium-m',
        :chost            => 'i686',
        :binhost          => 'x86'
      end   
    end 
    Chef::Log.info("Release: #{AMI_Release} make.conf updated")
  # when /^[2012|2013]/i 
    # Leave untouched
    # Chef::Log.info("Release: #{AMI_Release} doesn't need to update make.conf")
  else
    Chef::Log.info("Release: #{AMI_Release} doesn't need to update make.conf")
  end
else
  Chef::Log.info("Release: Unknown -- Cannot read /etc/engineyard/release -- not updating make.conf")
end
