ruby_block 'remove_Addtrust' do
    not_if "/etc/ca-certificates.conf | grep \"!mozilla/AddTrust_External_Root.crt\""
    block do
     
     buildarray = []
     ischange = false
     lines = IO.readlines('/etc/ca-certificates.conf')  
     for line in lines
      if (line.include? 'mozilla/AddTrust_External_Root.crt')
        buildarray << '!mozilla/AddTrust_External_Root.crt'
        ischange = true
      else
       buildarray << line
      end
     end
     
     if ischange
      writefile = File.open("/etc/ca-certificates.conf", "w")
      writefile.puts(buildarray)
      writefile.close
      system("update-ca-certificates")
     end
     action :run
    end
   end