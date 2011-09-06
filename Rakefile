require 'rake/testtask'''

task :default => :dev

desc "Run all tests"
Rake::TestTask.new do |t|
  t.libs.push "lib"
  t.ruby_opts = ["-r./config/load.rb"]
  t.test_files = FileList['test/*_test.rb', 'spec/*_spec.rb']
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
