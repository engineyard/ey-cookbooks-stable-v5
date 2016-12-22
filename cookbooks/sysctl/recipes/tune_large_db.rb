
thp_filename = '/sys/kernel/mm/transparent_hugepage/enabled'
if ::File.exists?(thp_filename)
  execute 'disable transparent huge pages when present' do
    command "echo never > #{thp_filename}"
  end

  sysctl "Adjust vm.dirty ratios for large instances" do
    variables({
      'vm.dirty_ratio' => '80',
      'vm.dirty_background_ratio' => '5',
      'vm.dirty_expire_centisecs' => '12000'
      })
  end
end
