require 'eventmachine'
require 'time'

class FakeSocketClient < EventMachine::Connection

  attr_writer :onopen, :onclose, :onmessage
  attr_reader :data

  def initialize
    @state = :new
    @data = []
  end

  def connection_completed
    @state = :open
    @onopen.call if @onopen
  end

  def receive_data(data)
    @data << data
    @onmessage.call(data) if @onmessage
  end

  def unbind
    @onclose.call if @onclose
  end

  def get(path)
    send_data("GET #{path} HTTP/1.1\r\n\r\n")
  end
end


class RetryingClient < FakeSocketClient
  def initialize(host, port, timeout)
    super()
    @host = host
    @port = port
    @timeout = timeout
    @end_time = nil
  end

  def post_init
    super
    @end_time = Time.new() + @timeout
  end

  def unbind
    if @state == :new and Time.new() < @end_time
      reconnect(@host, @port)
    else
      super
    end
  end

end

def try_connect(address, port, timeout)
  client = EM.connect(address, port, RetryingClient, address, port, timeout)
end
