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


  it "returns a list of boomarks as json" do

    get "/bookmarks", nil, {'HTTP_ACCEPT' => "application/json"}
    expect(last_response).to be_ok
    bookmarks = JSON.parse(last_response.body)
    expect(bookmarks).to be_instance_of(Array)

  end

  it "renders a list of boomarks as html" do

    get "/bookmarks", nil, {'HTTP_ACCEPT' => "application/json"}
    bookmarks = JSON.parse(last_response.body)

    get "/bookmarks", nil, {'HTTP_ACCEPT' => "text/html"}
    page = Nokogiri::HTML(last_response.body)
    expect(last_response).to be_ok
    expect(page.css('title')[0].text).to eq("Bookmarking App")
    expect(page.css('li').size).to eq(bookmarks.size)

  end

  it "renders an edit page for each bookmark" do

    get "/bookmarks", nil, {'HTTP_ACCEPT' => "application/json"}
    bookmarks = JSON.parse(last_response.body)

    bookmarks.each do |bookmark|
      get "/bookmarks/#{bookmark['id']}", nil, {'HTTP_ACCEPT' => "text/html"}
      page = Nokogiri::HTML(last_response.body)
      expect(last_response).to be_ok
      expect(page.at("form.edit")["action"]).to eq("/bookmarks/#{bookmark['id']}")
      expect(page.at("input[name='title']")["value"]).to eq(bookmark["title"])
      expect(page.at("input[name='url']")["value"]).to eq(bookmark["url"])
    end

  end

  it "renders an add a new bookmark page" do

    get "/bookmark/new", nil, {'HTTP_ACCEPT' => "text/html"}
    page = Nokogiri::HTML(last_response.body)
    expect(last_response).to be_ok
    expect(page.at("form.new")["action"]).to eq("/bookmarks")
    expect(page.at("input[name='title']")["value"]).to eq("")
    expect(page.at("input[name='url']")["value"]).to eq("")

  end

end