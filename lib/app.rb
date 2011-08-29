# The sinatra app to handle incoming requests
class Sopserve < Sinatra::Base

  def initialize
    @host = ENV["SOPCAST_HOST"]
    @user = ENV["SOPCAST_USER"]
    @pass = ENV["SOPCAST_PASS"]
  end

  get "/ls" do
    if @host.nil? || @user.nil? || @pass.nil?
      "Missing remote server credentials"
    else
      result = ""
      Net::SSH.start(@host, @user, :password => @pass) do |ssh|
        channel = ssh.open_channel do |ch|
          ch.exec "ls" do |ch, success|
            raise "could not execute command" unless success

            ch.on_data do |c, data|
              result += data
            end
          end
        end
        channel.wait()
      end
      result
    end
  end
end
