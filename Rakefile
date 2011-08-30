require 'rspec/core/rake_task'

desc "Run all RSpec tests"
RSpec::Core::RakeTask.new(:spec)

desc "Run an interactive console for the project"
task :console do
  sh "irb -r ./config/load"
end

desc "Run the application via rerun (auto-reloads on changes)"
local_port = 9393
task :dev do
  system "bundle exec rerun -- rackup config.ru --port=#{local_port} --server thin"
end

task :default => :spec
