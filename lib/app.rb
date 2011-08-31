
# Sopcast channel stream
class ChannelStream
  def initialize(host, user, pass, channel)
    @host = host
    @user = user
    @pass = pass
    @channel = channel
  end

  def each
    Net::SSH.start(@host, @user, :password => @pass) do |ssh|
      channel = ssh.open_channel { |ch|
        cmd = "sp-sc sop://broker.sopcast.com:3912/#{@channel} 3908 8908"
        ch.exec cmd do |ch, success|
          raise "could not execute command" unless success
          ch.on_data { |c, data|
            puts data
            yield data
          }
        end
      }
    end
  end
end


# The sinatra app to handle incoming requests
class Sopserve < Sinatra::Base
  register Sinatra::Synchrony

  def initialize
    @host = ENV["SOPCAST_HOST"]
    @user = ENV["SOPCAST_USER"]
    @pass = ENV["SOPCAST_PASS"]
  end

  get %r{/channel/([0-9]+)} do |channel|
    if @host.nil? || @user.nil? || @pass.nil?
      "Missing remote server credentials"
    else
      return ChannelStream.new(@host, @user, @pass, channel)
    end
  end
end
