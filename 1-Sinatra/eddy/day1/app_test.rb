require_relative "app"
require "rspec"
require "rack/test"

describe "Bookmarks Application" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "creates a new bookmark" do
    get "/bookmarks"
    bookmarks = JSON.parse last_response.body
    last_size = bookmarks.size

    post "/bookmarks",
      {:url => "http://www.test.com", :title => "tester"}

    last_response.status.should == 201
    last_response.body.should match(/\/bookmarks\/\d+/)

    get "/bookmarks"
    bookmarks = JSON.parse last_response.body
    expect(bookmarks.size).to eq(last_size + 1)
  end

  it "updates a bookmark" do
    post "/bookmarks",
      {:url=>"http://www.test.com", :title=>"Tester"}
    bookmark_uri = last_response.body
    id = bookmark_uri.split('/').last

    put "/bookmarks/#{id}", {:title => "Success"}
    last_response.status.should == 204

    get "/bookmarks/#{id}"
    retrived_bookmark = JSON.parse(last_response.body)
    expect(retrived_bookmark["title"]).to eq('Success')
  end

  # create a new bookmark
  # get total size
  # delete the recently entered
  # get total size again, assert old_size = new_size
  # get bookmark by id, assert res_code is 404
  it "deletes a bookmark" do
    get "/bookmarks"
    bookmarks = JSON.parse last_response.body
    old_size = bookmarks.size

    post "/bookmarks",
      {:url => "http://deleteme.com", :title => "Delete me!"}
    bookmark_uri = last_response.body
    id = bookmark_uri.split('/').last

    bookmarks = nil
    delete "/bookmarks/#{id}"
    get "/bookmarks"
    bookmarks = JSON.parse last_response.body
    new_size  = bookmarks.size

    expect(old_size).to eq(new_size)
  end

end