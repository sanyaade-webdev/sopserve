require 'ssh'
require 'scraper'

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
    def initialize(connection, url)
      @conn = connection
      @url = url
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
      @sopcast = @conn.remote_process(command, Sopcast::Process, block)
      @sopcast.exec
    end
  end
end

# The sinatra app to handle incoming requests
class Sopserve < Sinatra::Base
  register Sinatra::Synchrony

  def initialize(host = nil, user = nil, pass = nil)
    host |= ENV["SOPCAST_HOST"]
    user |= ENV["SOPCAST_USER"]
    pass |= ENV["SOPCAST_PASS"]
    @connection = SSH::Connection.new(host, user, pass)
   end

  def resource_url(id, type)
    "/#{type}?id=#{id}"
  end

  def prepare_resources(resources, type)
    result = []
    resources.each { |resource|
      resource[:url] = resource_url(resource[:id], type)
      resource.delete(:id)
      result << resource
    }
    result
  end

  get '/event' do
    content_type :json, :charset => 'utf-8'
    streams = Event.new(params[:id]).get_streams()
    prepare_resources(streams, :stream).to_json
  end

  get '/sport' do
    content_type :json, :charset => 'utf-8'
    leadtime = params[:leadtime].class == nil ? 30 : params[:leadtime].to_i
    events = Sport.new(params[:id]).get_current_events(leadtime)
    prepare_resources(events, :event).to_json
  end

  get "/" do
    return "here"
  end

  get "/sports" do
    content_type :json, :charset => 'utf-8'
    sports = SportTypes.new().get_all()
    prepare_resources(sports, :sport).to_json
  end

  get "/stream" do
    url = Stream.new(params[:id]).url
    Sopcast::StreamHandler.new(@connection, url).tap { |stream|
      env['async.close'].callback { stream.close }
    }
  end
end
