require 'rubygems'
require 'eventmachine'


SOPCAST='bundle exec ruby ' + File.join(File.dirname(__FILE__), 'mock_sopcast.rb')
BROKER='sop://broker.sopcast.com:3912'
LOCALPORT='3908'
PLAYPORT=
CHANNEL=


class SopcastProcess < EM::Connection

  def initialize(client)
    super
    @client = client
  end

  def post_init
    @client.process_started
  end

  def receive_data data
    puts data
  end

  def unbind
    @client.process_stopped
  end
end


class SopcastClient
  attr_writer :onstarted, :onstopped

  def initialize(port)
    @play_port = port
    @sopcast = SOPCAST
    @broker = BROKER
    @local_port = LOCALPORT
  end

  def command
    channel_id = 0
    "#{@sopcast} #{@broker}/#{channel_id} #{@local_port} #{@play_port}"
  end

  def run
    EM.popen(command, SopcastProcess, self)
  end

  def stop

  end

  def process_started
    @onstarted.call if @onstarted
  end

  def process_stopped
    @onstopped.call if @onstopped
  end
end
