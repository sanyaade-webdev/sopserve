# Makes Net::SSH work with eventmachine's runloop.
# Code ripped from https://github.com/joshado/eventmachine-async-block and
# tweaked to expect Ruby 1.9's fibers.
module Net;
  class FiberSelect
    attr_reader :result

    def initialize(fiber)
      @fiber = fiber
      @connections = []
      @result = [[],[],[]]
    end

    def watch(io, reads, writes)
      @connections << EM.watch(io) { |conn|
        conn.instance_variable_set( :@select, self )
        def conn.notify_readable
          @select.finish([[@io], [], []])
        end
        def conn.notify_writable
          @select.finish([[], [@io], []])
        end
        conn.notify_readable = reads
        conn.notify_writable = writes
      }
    end

    def set_timeout(timeout)
      @timer = EM.add_timer( timeout == 0 ? 0.1 : timeout ) { self.finish() }
    end

    def finish(result=nil)
      @timer && EM::cancel_timer(@timer)
      @connections.each { |conn| conn.detach }
      @result = result ? result : @result
      @fiber.resume
    end

    def wait
      Fiber.yield
      @result
    end
  end

  class SSH::Compat
    def self.io_select(read_array, write_array=nil, error_array=nil,timeout=nil)
      raise "Error array not supported" if error_array
      write_array ||= []
      select = FiberSelect.new(Fiber.current).tap { |select|
        (read_array + write_array).uniq.each { |io|
          select.watch(io, read_array.include?(io), write_array.include?(io))
        }
      }
      select.set_timeout(timeout) if timeout
      select.wait()
    end
  end
end
