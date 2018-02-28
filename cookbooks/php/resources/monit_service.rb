#
# Cookbook:: php
# Resource:: monit_service
#
# Author:: Jevgenij Sevostjanov <jevgenij@lmiw.net>

resource_name :monit_service

property :service_name, String, name_property: true

action :start do
  execute "monit start #{new_resource.service_name}" do
    command "/usr/bin/monit start #{new_resource.service_name}"
    not_if do
      "/usr/bin/monit status #{new_resource.service_name} | grep -Eq 'Initializing|Running'"
    end
  end
end

action :restart do
  execute "monit restart #{new_resource.service_name}" do
    command "/usr/bin/monit restart #{new_resource.service_name}"
  end
end

action :restartall do
  execute "monit restart all services" do
    command "/usr/bin/monit restart all"
  end
end

action :reload do
  execute "monit reload" do
    command "/usr/bin/monit reload"
  end
end
