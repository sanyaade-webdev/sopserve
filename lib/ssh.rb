module SSH
  # SSH::RemoteProcess is the base class for all process instances
  # returned from the {SSH::PersistentConnection#process} method.
  class RemoteProcess
    def self.new(connection, channel, *args)
      allocate.instance_eval do
        initialize(*args)
        set_channel_callbacks(channel)
        @connection = connection
        @channel = channel
        self
      end
    end

    def exec
      @connection.loop
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

    def set_channel_callbacks(channel)
      channel.on_request "exit-status", &Proc.new{ |c, d| on_exit(d.read_long) }
      channel.on_data { |c, data | on_stdout(data) }
      channel.on_extended_data { |c, data | on_stderr(data) }
    end
  end

  # SSH::ConnectionRegistry manages open SSH connections, reusing them
  # as required.
  # TODO: implement cleanup.
  class ConnectionRegistry
    def initialize
      @connections = {}
    end

    def get_connection(host, user, pass)
      Net::SSH.start(host, user, :password => pass)
    end
  end


  # SSH::PersistentConnection is a class used to create and manage a
  # reusable, long-lived connection to an SSH server.
  class PersistentConnection
    def initialize(host, user, pass, registry = ConnectionRegistry.new)
      raise "Missing server credentials" if host.nil? || user.nil? || pass.nil?
      @host, @user, @pass, @registry = host, user, pass, registry
    end

    def create_handler_class(handler, *args)
      klass = Class.new(SSH::RemoteProcess){ include handler }
    end

    def remote_process(cmd, handler, *args)
      connection = @registry.get_connection(@host, @user, @pass)
      klass = create_handler_class(handler)
      klass.new(connection, open_channel(connection, cmd), *args)
    end

    private

    def open_channel(connection, cmd)
      return connection.open_channel { |channel|
        channel.exec cmd do |c, success|
          raise "Command failed: #{cmd}" if not success
        end
      }
    end
  end
end
