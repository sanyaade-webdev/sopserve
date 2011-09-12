$: << File.expand_path('../../lib',__FILE__)

# ensure bundler runs
require 'rubygems'
require 'bundler/setup'

# bundled
require 'active_support/core_ext'
require 'base64'
require 'chronic'
require 'htmlentities'
require "em-synchrony/em-http"
require 'eventmachine'
require 'json'
require 'net/ssh'
require 'nokogiri'
require 'sinatra/base'
require 'sinatra/synchrony'

# local extensions
require 'ext/async_ssh'
require 'ext/ssh'

# app
require 'app'
