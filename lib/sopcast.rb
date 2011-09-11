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
