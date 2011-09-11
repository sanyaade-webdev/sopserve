require 'rake/testtask'''

task :default => :test

desc "Run all tests"
Rake::TestTask.new do |t|
  t.libs.push ["lib", "spec"]
  t.test_files = FileList['spec/*_spec.rb']
  t.verbose = true
end

desc "Run an interactive console for the project"
task :console do
  sh "irb -r ./config/load"
end

desc "Run the application via rerun (auto-reloads on changes)"
task :dev do
  system "bundle exec rerun -- rackup --server=thin"
end

desc "Run the tests via watchr (auto-reloads on changes)"
task :tdd do
  system "bundle exec watchr spec/spec.watchr"
end
