ENV['RACK_ENV'] = 'test'

require_relative '../config/load'
Bundler.require(:test)

Sinatra::Synchrony.patch_tests!
