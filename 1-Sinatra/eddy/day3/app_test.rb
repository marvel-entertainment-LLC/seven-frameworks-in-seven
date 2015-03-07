require_relative "app"
require "rspec"
require "rack/test"

describe "Bookmarks Application" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end


  it "adds tags to existing bookmark" do
    post_data = {
      :url => 'http://test.com',
      :title => 'test',
      :tagsAsString => 'test1,test2'
    }
    post "/bookmarks", post_data
    id = last_response.body[/\d+/]

    get "/bookmarks/#{id}"
    bookmark = JSON.parse last_response.body
    original_tags = bookmark['tagList']
    tags = original_tags.clone << "test3"

    # add new tag 'test3'
    put "/bookmarks/#{id}", post_data.merge({
        :tagsAsString => tags.join(',')
      })
    expect(last_response.status).to be(204)

    get "/bookmarks/#{id}"
    bookmark2 = JSON.parse last_response.body
    tag_diff  = bookmark2['tagList'] - original_tags
    expect(tag_diff).to eq(["test3"])

  end



  it "sends an error code for invalid create request" do
    post "/bookmarks", {:url => 'test', :title => "Test"}
    expect(last_response.status).to be(400)
  end

  it "sends an error code for invalid update request" do
    get "/bookmarks"
    bookmarks = JSON.parse(last_response.body)
    id = bookmarks.first['id']

    put "/bookmarks/#{id}", { :url => "invalid" }
    expect(last_response.status).to be(400)
  end


end