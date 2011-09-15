libdir = File.expand_path('../lib', File.dirname(__FILE__))
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

# bundled gems
require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

# local extensions
require 'ext/async_ssh'
require 'ext/ssh'

# app
require 'app'
