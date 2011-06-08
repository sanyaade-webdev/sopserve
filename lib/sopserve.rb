#!/usr/bin/env ruby

require 'rubygems' if RUBY_VERSION < '1.9'
require 'bundler/setup'
require 'sinatra'
require 'sinatra/async'
require 'eventmachine'
require 'daemon_controller'


PORT = 8908
PID_FILE = '/tmp/sopcastd.pid'
LOG_FILE = 'sopserve.log'
SOPCAST_LOG = 'sopcastd.log'
TIMEOUT = 10
THIS_DIR = File.dirname(File.expand_path(__FILE__))


configure :development do |conf|
  enable :logging, :dump_errors, :raise_errors
end


class StreamListener < EM::Connection
  def initialize(client)
    super
    @client = client
    @skipped_header = false
  end

  def post_init
    send_data("GET / HTTP/1.1")
  end

  def receive_data(data)
    delimiter = /[\n][\r]*[\n]/
    if !@skipped_header and data =~ delimiter
      @skipped_header = true
      header, data =  data.split(delimiter)
    end
    if @skipped_header
      @client.send_data(data, self)
    end
  end

  def unbind
    @client.close
  end
end


class StreamClient
  include EM::Deferrable

  def each(&block)
    puts "New connection"
    @block = block
  end

  def send_data(data, listener)
    if @block
      @block.call(data)
    else
      listener.close_connection
    end
  end

  def close
    if @block
      @block = nil
      puts "Connection closed"
      succeed
    end
    super
  end
end


class SopServe < Sinatra::Base
  register Sinatra::Async

  def initialize
    super
    @port = PORT
    @pid_file = PID_FILE
    @log_file = SOPCAST_LOG
    @timeout = TIMEOUT
  end

  def start_command(channel_id)
    opts = "-c #{channel_id} -p #{@port} -P #{@pid_file} -l #{@log_file}"
    "#{THIS_DIR}/sopcastd #{opts}"
  end

  def ping_sopcast_server
    begin
      TCPSocket.new('127.0.0.1', @port)
      true
    rescue SystemCallError
      false
    end
  end

  def daemon(channel_id=0)
    options = {
      :identifier    => 'Sopcast Daemon',
      :start_command => start_command(channel_id),
      :ping_command  => method(:ping_sopcast_server),
      :pid_file      => @pid_file,
      :log_file      => @log_file,
      :start_timeout => @timeout,
      :stop_timeout  => @timeout
    }
    DaemonController.new(options)
  end

  def set_listener(listener)
    @listener = listener
  end

  get '/status' do
    daemon.running? ? 'running' : 'not running'
  end

  get '/start/:channel' do |channel|
    daemon(channel).start
    if daemon.running?
      redirect "/stream"
    end
  end

  get '/stop' do
    daemon.stop
  end

  aget '/stream' do
    client = StreamClient.new
    EM.connect('127.0.0.1', PORT, StreamListener, client)
    body client
  end

  get '/streams' do
    'No running streams'
  end
end
