require_relative "app"
require "rspec"
require "rack/test"
require "json"

describe "Bookmarking App" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "creates a new bookmark" do
    get "/bookmarks"
    bookmarks = JSON.parse(last_response.body)
    last_size = bookmarks.size # (1)

    post "/bookmarks",
      {:url => "http://www.test.com", :title => "Test"}
    
    expect(last_response.status).to eq(201)
    expect(last_response.body).to match(/\/bookmarks\/\d+/) # (2)

    get "/bookmarks"
    bookmarks = JSON.parse(last_response.body)
    expect(bookmarks.size).to eq(last_size + 1) # (3)

  end

  it "updates a bookmark" do
    post "/bookmarks",
      {:url => "http://www.test.com", :title => "Test"}
    bookmark_uri = last_response.body
    id = bookmark_uri.split("/").last # (4)
    
    put "/bookmarks/#{id}", {:title => "Success"} # (5)
    expect(last_response.status).to eq(204)

    get "/bookmarks/#{id}"
    retrieved_bookmark = JSON.parse(last_response.body)
    expect(retrieved_bookmark["title"]).to eq("Success") # (6)
  end

  it "deletes a bookmark" do
    post "/bookmarks",
      {:url => "http://www.test.com", :title => "Test"}
    get "/bookmarks"
    bookmarks = JSON.parse(last_response.body)
    last_size = bookmarks.size
    
    delete "/bookmarks/#{bookmarks.last['id']}"
    expect(last_response.status).to eq(200)

    get "/bookmarks"
    bookmarks = JSON.parse(last_response.body)
    expect(bookmarks.size).to eq(last_size - 1)
  end
end