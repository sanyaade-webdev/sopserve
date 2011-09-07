$: << File.expand_path('../../lib',__FILE__)

# bundled
require 'base64'
require 'hpricot'
require "em-synchrony/em-http"
require 'eventmachine'
require 'json'
require 'net/ssh'
require 'sinatra/base'
require 'sinatra/synchrony'

# local
require 'app'
require 'net/async_ssh'

