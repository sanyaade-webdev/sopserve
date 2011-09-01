# Persistent server connection
class ServerConnection
  def initialize(host, user, pass, timeout=60)
    @host, @user, @pass, @timeout  = host, user, pass, timeout
  end

  def exec(cmd, params = {})
    open_channel(cmd, params)
    schedule_cleanup
    session.loop
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

  def open_channel(cmd, params = {})
    return session.open_channel { |channel|
      channel.on_request "exit-status", &on_exit = Proc.new { |c, data|
        params[:on_exit].call(data.read_long) if params[:on_exit]
      }
      channel.on_data { |c, data |
        params[:on_stdout].call(data) if params[:on_stdout]
      }
      channel.on_extended_data { |c, data |
        params[:on_stderr].call(data) if params[:on_stderr]
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
    puts "Sopcast started"
    @connection.start_forwarding_port(@port, "localhost", @port)
    EM::Timer.new(15) {
      http = EventMachine::HttpRequest.new("http://localhost:#{@port}").get
      http.stream { |chunk| puts chunk.length; }#EM.next_tick { send_data(chunk) } }
      http.errback { puts "Couldn't initiate stream" }
    }
  end

  def process_exited(status)
    puts "Soptcast stopped"
    @connection.stop_forwarding_port(@port)
    finish(status)
  end

  def process_stdout(output)
    #puts output
  end

  def process_stderr(output)
    puts "Exec failed: %s" % output
  end

  def send_data(data)
    @output.call(data)
  end

  def finish(exit_code)
    puts "Process exited with status: #{exit_code}\n"
  end

  def command
    "sp-sc-auth sop://broker.sopcast.com:3912/#{@channel} 3908 #{@port}"
  end

  def each(&block)
    @output = block
    @fiber = Fiber.current
    @connection.exec(command,
                     :on_start => method(:process_started),
                     :on_exit => method(:process_exited),
                     :on_stdout => method(:process_stdout),
                     :on_stderr => method(:process_stderr))
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
