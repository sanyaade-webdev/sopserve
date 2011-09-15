libdir = File.expand_path('lib', File.dirname(__FILE__))
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'rake/testtask'

task :default => :test
Rake::TestTask.new do |t|
  t.libs.push ["lib", "spec"]
  t.test_files = FileList['spec/*_spec.rb']
  t.verbose = true
end

desc "Run the application"
task :run do
  system "bundle exec rackup --server=thin"
end

desc "Run the application (auto-reloads on changes)"
task :dev do
  system "bundle exec rerun -- rackup --server=thin"
end

desc "Run the tests continuously"
task :tdd do
  system "bundle exec watchr spec/spec.watchr"
end

desc "Run an interactive console for the project"
task :console do
  system "bundle exec irb -r ./config/load"
end

desc "Deploy code to the production server"
task :deploy => ['vlad:update', 'vlad:bundle:install']

begin
  require "vlad"
  Vlad.load :scm => :git
rescue LoadError
end


