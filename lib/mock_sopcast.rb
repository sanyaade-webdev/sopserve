#!/usr/bin/env ruby

require 'rubygems'
require 'eventmachine'
require 'evma_httpserver'


class MockSopcastClient < EM::Connection
  include EM::HttpServer

  def post_init
    super
    puts "client connecting"
  end

  def process_http_request
    resp = EM::DelegatedHttpResponse.new(self)
    resp.status = 200
    resp.content = "Hello World!"
    resp.send_response
  end

  def unbind
    puts "client disconnecting"
    super
  end
end


EM.run do
  port = ARGV[2]
  puts "Serving on port #{port}"
  EM.start_server('0.0.0.0', port, MockSopcastClient)
end
