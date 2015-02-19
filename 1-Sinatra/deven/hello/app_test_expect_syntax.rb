require_relative "app"
require "rspec"
require "rack/test"

describe "Hello application" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end
  
  # RSpec 2.11+ new expecation syntax
  # http://rspec.info/blog/2012/06/rspecs-new-expectation-syntax/
  # v2.11+ throws deprecation warning when using :should syntax
  it "says hello" do
    get "/hello"
    expect(last_response).to be_ok
    expect(last_response.body).to eq("Hello, Sinatra")
  end
end
