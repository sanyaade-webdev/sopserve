$: << File.expand_path('../../lib',__FILE__)

# bundled gems
require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

# local extensions
require 'ext/async_ssh'
require 'ext/ssh'

# app
require 'app'
