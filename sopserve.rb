#!/usr/bin/env ruby

require 'rubygems' if RUBY_VERSION < '1.9'
require 'bundler/setup'
require 'sinatra/base'
require 'daemon_controller'


PORT = 8908
PID_FILE = "/tmp/sopcastd.pid"
LOG_FILE = "sopcastd.log"
TIMEOUT = 10
THIS_DIR = File.dirname(File.expand_path(__FILE__))


class SopServer < Sinatra::Base
  def initialize
    super
    @port = PORT
    @pid_file = PID_FILE
    @log_file = LOG_FILE
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

  def create_daemon(channel_id=0)
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

  get '/status' do
    daemon = create_daemon()
    daemon.running? ? "running" : "not running"
  end

  get '/start/:channel' do |channel|
    daemon = create_daemon(channel)
    daemon.start
    redirect '/status'
  end

  get '/stop' do
    daemon = create_daemon()
    daemon.stop
    redirect '/status'
  end
end
