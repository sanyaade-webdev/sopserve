# Persistent server connection
class ServerConnection
  def initialize(host, user, pass, timeout=60)
    @host, @user, @pass, @timeout  = host, user, pass, timeout
  end

  def exec(cmd, params = {})
    status = 0
    schedule_cleanup
    session.open_channel { |c|
      c.on_request("exit-status", &Proc.new{|c, data| status = data.read_long })
      c.on_data { |c, data | params[:on_data].call(data)} if params[:on_data]
      c.exec cmd do |c, success|
        raise "Command failed: #{cmd}" if not success
        params[:on_start].call() if params[:on_start]
      end
    }
    session.loop
    return status
  end

  def cleanup
    if not @session.nil? and not @session.busy?
      @session = @session.close
      puts "Session timed out"
    else
      schedule_cleanup
    end
  end

  private

  def schedule_cleanup
    @timer |= EM.add_timer(@timeout) { self.cleanup() }
  end

  def session
    raise "Missing server credentials" if @host.nil? || @user.nil? || @pass.nil?
    @session ||= Net::SSH.start(@host, @user, :password => @pass)
  end
end


# Sopcast channel stream
class ChannelStream
  def initialize(connection, channel)
    @connection = connection
    @channel = channel
  end

  def process_started
    puts "Started"
  end

  def process_stdout(output)
    puts output
  end

  def command
    "sp-sc sop://broker.sopcast.com:3912/#{@channel} 3908 8908"
  end

  def each(&block)
    status = @connection.exec(command,
                              :on_start => method(:process_started),
                              :on_data => method(:process_stdout))
    puts "Exit status: #{status}"
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
