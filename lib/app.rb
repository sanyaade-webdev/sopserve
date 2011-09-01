# Persistent server connection
class ServerConnection
  def initialize(host, user, pass, timeout=60)
    @host, @user, @pass, @timeout  = host, user, pass, timeout
  end

  def exec(cmd, params = {})
    status = 0
    on_exit = Proc.new { |c, data|
      status = data.read_long
      params[:on_exit].call(status) if params[:on_exit]
    }
    open_channel(cmd, on_exit, params)
    schedule_cleanup
    session.loop
    return status
  end

  def start_forwarding_port(localport, address, port)
    session.forward.local(localport, address, port)
  end

  def stop_forwarding_port(localport)
    session.forward.cancel_local(localport)
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

  def open_channel(cmd, on_exit, params = {})
    return session.open_channel { |channel|
      channel.on_request("exit-status", &on_exit)
      channel.on_data { |c, data |
        params[:on_data].call(data) if params[:on_data]
      }
      channel.exec cmd do |c, success|
        exec_failed(cmd) if not success
        params[:on_start].call() if params[:on_start]
      end
    }
  end

  def exec_failed cmd
    raise "Command failed: #{cmd}"
  end

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
    @port = 8908
  end

  def process_started
    @output.call("Started")
  end

  def process_exited(status)
    @status = status
    @connection.stop_forwarding_port(@port)
  end

  def process_stdout(output)
    send_data(output)
  end

  def send_data(data)
    @output.call(data)
  end

  def command
    "sp-sc sop://broker.sopcast.com:3912/#{@channel} 3908 #{8908}"
  end

  def each(&block)
    @output = block
    @connection.start_forwarding_port(@port, "localhost", @port)
    @connection.exec(command,
                     :on_start => method(:process_started),
                     :on_exit => method(:process_exited),
                     :on_data => method(:process_stdout))
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
