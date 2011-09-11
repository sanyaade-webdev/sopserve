require 'spec_helper.rb'

describe Sopserve do
  include Rack::Test::Methods

  before do
    stub_request(:get, 'http://livetv.ru/en/allupcoming/')
      .to_return(:body => get_test_html(:sports_index), :status => 200)
  end

  def app
    Sopserve.new
  end

  def get_test_html(file_name)
    File.new(File.expand_path("../data/#{file_name}.html", __FILE__)).read()
  end

  it "can extract the list of sports from the livetv website" do
    get "/sports"
    sports = JSON.parse(last_response.body).collect { |sport| sport["name"] }
    assert_empty ["Football", "Ice Hockey", "Basketball", "Tennis",
                  "Volleyball", "Racing", "Rugby League", "Baseball",
                  "Beach Soccer", "American Football", "Billiard",
                  "Rugby Union", "Cycling", "Cricket"] - sports
  end
end
