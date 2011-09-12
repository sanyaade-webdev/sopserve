require 'rake/testtask'
require 'vlad'

Vlad.load :scm => :git

task :default => :test
Rake::TestTask.new do |t|
  t.libs.push ["lib", "spec"]
  t.test_files = FileList['spec/*_spec.rb']
  t.verbose = true
end

desc "Run an interactive console for the project"
task :console do
  system "irb -r ./config/load"
end

desc "Run the application (auto-reloads on changes)"
task :dev do
  system "bundle exec rerun -- rackup --server=thin"
end

desc "Run the tests continuously"
task :tdd do
  system "bundle exec watchr spec/spec.watchr"
end
