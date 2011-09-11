ENV['RACK_ENV'] = 'test'

require_relative '../config/load'
require 'minitest/spec'
require 'minitest/autorun'
require 'rack/test'
require 'redgreen'
require 'webmock/minitest'

Sinatra::Synchrony.patch_tests!
