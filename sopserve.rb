#!/usr/bin/env ruby

require 'rubygems' if RUBY_VERSION < '1.9'
require 'bundler/setup'
require 'sinatra/base'


class SopServer < Sinatra::Base
  get '/' do
    'Not implemented'
  end
end
