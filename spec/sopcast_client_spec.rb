require 'spec_helper'
require 'sopcast_client'
require 'eventmachine'

describe SopcastClient do
  after(:each) do
    if @client != nil
      @client.stop
      @client = nil
    end
  end

  it 'should respond on the specified port when connected to a valid stream' do
    port = 6816
    connected = false
    timeout = 5
    EM.run {
      @client = SopcastClient.new(port)
      @client.run()
      socket = try_connect("127.0.0.1", port, timeout)
      socket.onopen = lambda {
        connected = true
        EM.stop
      }
      socket.onclose = lambda {
        EM.stop
      }
    }
    connected.should be_true
  end
end
