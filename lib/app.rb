# The sinatra app to handle incoming requests
class Sopserve < Sinatra::Base

  def initialize
    @host = ENV["SOPCAST_HOST"]
    @user = ENV["SOPCAST_USER"]
    @pass = ENV["SOPCAST_PASS"]
  end

  get "/" do
    if @host.nil? || @user.nil? || @pass.nil?
      "Missing remote server credentials"
    else
      "ok"
    end
  end

end
