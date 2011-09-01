$: << File.expand_path('../../lib',__FILE__)

# bundled
require 'sinatra/base'
require 'sinatra/synchrony'
require 'eventmachine'
require 'net/ssh'

# local
require 'app'
require 'net/async_ssh'

