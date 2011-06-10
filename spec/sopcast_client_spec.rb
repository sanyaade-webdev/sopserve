require 'spec_helper'
require 'sopcast_client'
require 'eventmachine'

describe SopcastClient do
  before(:each) do
    @port = 6816
    @start_timeout = 5
    @client = SopcastClient.new(@port)
  end

  after(:each) do
    @client.stop
    @client = nil
  end

  def connection_test(onopen)
    EM.run {
      @client.run()
      socket = try_connect("127.0.0.1", @port, @start_timeout)
      socket.onopen = lambda {
        onopen.call(socket)
      }
      socket.onclose = lambda {
        EM.stop
      }
    }
  end

  it 'should respond on the specified port when connected to a valid stream' do
    connected = false
    test = lambda { |connection|
      connected = true
      EM.stop
    }
    connection_test(test)
    connected.should be_true
  end

  it 'should respond on the player port using the HTTP protocol' do
    response_data = ""
    test = lambda { |connection|
      connection.onmessage = lambda { |data|
        response_data = data
        EM.stop
      }
      connection.get("/")
    }
    connection_test(test)
    response_data.should match(/HTTP\/1.1 200/)
  end
end
