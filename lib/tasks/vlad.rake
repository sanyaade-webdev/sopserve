begin
  require "vlad"
  require "bundler/vlad"

  begin
    Vlad.load :scm => :git
  rescue Exception => e
    puts "Error loading vlad: #{e}"
    exit
  end

  set :skip_scm, false
  set :bundle_cmd, ["source ~/.rvm/scripts/rvm",
                    "rvm rvmrc untrust #{release_path}",
                    "bundle"].join(" && ")
  set :service_cmd, "sudo service"

  namespace :vlad do
    desc "Deploy code to the production server"
    task :deploy => ['vlad:update', 'vlad:bundle:install']
  end
rescue LoadError
end

