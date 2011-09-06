require 'ssh'

module Sopcast
  # Remote sopcast process handler
  module Process
    def initialize(output_block)
      @output_block = output_block
    end

    def on_stdout(data)
      @output_block.call(data)
    end
  end

  # Stream request handler
  class StreamHandler
    def initialize(connection, channel)
      @conn = connection
      @channel = channel
      @port = 8908
    end

    def close
      @sopcast.kill
    end

    def wrapper_script # EVIL (but easy)!
      script_path = File.expand_path('../helper/sopcast.sh',__FILE__)
      eval("\"" + File.open(script_path, "r").read + "\"").gsub("'", "\"")
    end

    def command
      "bash -c '#{wrapper_script}'"
    end

    def each(&block)
      begin
        @sopcast = @conn.remote_process(command, Sopcast::Process, block)
        @sopcast.exec
      rescue Exception => e
        #puts e.backtrace
      end
    end
  end
end

# The sinatra app to handle incoming requests
class Sopserve < Sinatra::Base
  register Sinatra::Synchrony

  def initialize
    @connection = SSH::PersistentConnection.new(ENV["SOPCAST_HOST"],
                                                ENV["SOPCAST_USER"],
                                                ENV["SOPCAST_PASS"])
  end

  get %r{/channel/([0-9]+)} do |channel|
    Sopcast::StreamHandler.new(@connection, channel).tap { |stream|
      env['async.close'].callback { stream.close }
    }
  end
end
