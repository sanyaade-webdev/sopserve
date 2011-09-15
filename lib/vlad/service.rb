require 'vlad'

class Vlad::Service
  set :service, Vlad::Service.new
  set :service_cmd, "service"

  def start(name)
    "#{service_cmd} #{name} start"
  end

  def stop(name)
    "#{service_cmd} #{name} stop"
  end

  def restart(name)
    "#{service_cmd} #{name} restart"
  end
end
