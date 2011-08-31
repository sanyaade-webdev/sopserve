# Persistent server connection
class ServerConnection
  def initialize(host, user, pass, timeout=60)
    @host, @user, @pass, @timeout  = host, user, pass, timeout
  end

  def schedule_cleanup
    @timer |= EM.add_timer(@timeout) { self.cleanup() }
  end

  def cleanup
    if not @session.nil? and not @session.busy?
      @session = @session.close
      puts "Session timed out"
    else
      schedule_cleanup
    end
  end

  def session
    raise "Missing server credentials" if @host.nil? || @user.nil? || @pass.nil?
    @session ||= Net::SSH.start(@host, @user, :password => @pass)
  end

  def exec(cmd, output_callback)
    schedule_cleanup
    session.exec! cmd do |ch, stream, data|
      puts "Executing cmd: #{cmd}"
      output_callback.call(data) if stream == :stdout
    end
  end
end


# Sopcast channel stream
class ChannelStream
  def initialize(connection, channel)
    @connection = connection
    @channel = channel
  end

  def each
    cmd = "sp-sc sop://broker.sopcast.com:3912/#{@channel} 3908 8908"
    read_callback = Proc.new { |data| yield data }
    @connection.exec(cmd, read_callback)
  end
end


# The sinatra app to handle incoming requests
class Sopserve < Sinatra::Base
  register Sinatra::Synchrony

  def initialize
    @connection = ServerConnection.new(ENV["SOPCAST_HOST"],
                                       ENV["SOPCAST_USER"],
                                       ENV["SOPCAST_PASS"])
  end

  get %r{/channel/([0-9]+)} do |channel|
    return ChannelStream.new(@connection, channel)
  end
end
