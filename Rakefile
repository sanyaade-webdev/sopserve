require 'rspec/core/rake_task'

task :default => :spec

desc "Run all RSpec tests"
RSpec::Core::RakeTask.new(:spec) do |test|
  test.rspec_opts = "-r ./config/load"
end

desc "Run an interactive console for the project"
task :console do
  sh "irb -r ./config/load"
end

desc "Run the application via rerun (auto-reloads on changes)"
task :dev do
  system "bundle exec rerun -- rackup --server=thin"
end


