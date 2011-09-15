require 'vlad'
require 'vlad/service'

namespace :vlad do
  set :web_service, "nginx"

  namespace :web do
    desc "Start the web servers."
    remote_task :start, :roles => :web do
      run "#{service.start web_service}"
    end

    desc "Gracefully stop the web servers."
    remote_task :stop, :roles => :web do
      run "#{service.stop web_service}"
    end
  end
end
