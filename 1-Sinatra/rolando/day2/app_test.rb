require_relative "app"
require "rspec"
require "rack/test"
require "json"
require "nokogiri" # http://ruby.bastardsbook.com/chapters/html-parsing/

describe "Bookmarking App" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  # Get the JSON to compare the rendered html against but also implicitly tests "returns a list of bookmarks as json"
  before(:each) do
    get "/bookmarks", nil, {'HTTP_ACCEPT' => "application/json"}
    last_response.should be_ok
    @bookmarks = JSON.parse(last_response.body)
    @bookmarks.should be_instance_of(Array)
  end

  it "renders a list of boomarks as html" do

    get "/bookmarks", nil, {'HTTP_ACCEPT' => "text/html"}
    last_response.should be_ok
    page = Nokogiri::HTML(last_response.body)
    page.css('title')[0].text.should eq("Bookmarking App")
    page.css('li').size.should eq(@bookmarks.size)

  end

end