class Docker < Inspec.resource(1)
  name 'docker'

  def graph_directory
    info.stdout.match(/Docker Root Dir: (.*)$/)[1]
  end

  def storage_driver
    info.stdout.match(/Storage Driver: (.*)$/)[1]
  end

  private
  def info
    @result = inspec.backend.run_command '/usr/bin/docker info'
  end
end
