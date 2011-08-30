require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

task :default => :test

task :console do
  sh "irb -r ./config/load"
end

local_port = 9393
task :dev do
  system "bundle exec rerun -- rackup config.ru --port=#{local_port} --server thin"
end
