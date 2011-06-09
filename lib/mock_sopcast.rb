#!/usr/bin/env ruby

require 'rubygems'
require 'eventmachine'


PORT = ARGV[2]


class MockSopcastClient < EM::Connection
  def post_init
    puts "client connecting"
  end

  def unbind
    puts "client disconnecting"
  end
end


EM.run do
  EM.start_server('0.0.0.0', PORT, MockSopcastClient)
end
