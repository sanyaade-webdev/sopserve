module SSH
  # SSH::RemoteProcess is the base class for all process instances
  # returned from the {SSH::PersistentConnection#process} method.
  class RemoteProcess
    attr_accessor :channel

    def self.new(session, chan, *args)
      allocate.instance_eval do
        @session = session
        self.channel = chan
        initialize(*args)
        self
      end
    end

    def exec
      @session.loop
    end

    def kill
      @channel.close
    end

    def on_exit(exit_status)
    end

    def on_stdout(data)
    end

    def on_stderr(data)
    end

    private

    def channel=(chan)
      chan.on_request "exit-status", &Proc.new{ |c, d| on_exit(d.read_long) }
      chan.on_data { |c, data | on_stdout(data) }
      chan.on_extended_data { |c, data | on_stderr(data) }
      @channel = chan
    end
  end

  # SSH::PersistentConnection is a class used to create and manage a
  # reusable, long-lived connection to an SSH server.
  class PersistentConnection
    def initialize(host, user, pass, timeout=60)
      @host, @user, @pass, @timeout  = host, user, pass, timeout
    end

    def create_handler_class(handler, *args)
      klass = Class.new(SSH::RemoteProcess){ include handler }
    end

    def process(cmd, handler, *args)
      klass = create_handler_class(handler)
      klass.new(session, open_channel(cmd), *args)
      # schedule_cleanup
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

    def open_channel(cmd)
      return session.open_channel { |channel|
        channel.exec cmd do |c, success|
          raise "Command failed: #{cmd}" if not success
        end
      }
    end

    def schedule_cleanup
      @timer |= EM.add_timer(@timeout) { self.cleanup() }
    end

    def session
      raise "Missing server credentials" if @host.nil? || @user.nil? || @pass.nil?
      @session ||= Net::SSH.start(@host, @user, :password => @pass)
    end
  end
end
