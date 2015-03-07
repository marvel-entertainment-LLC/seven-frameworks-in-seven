require_relative "app"
require "rspec"
require "rack/test"
require "nokogiri"
require "digest"

describe "Bookmarks Application" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  # helper method to extract info from xml nodes
  # based on what's specified in the block
  def get_xml_info(xml, xp)
    return '' unless block_given?
    doc = Nokogiri.XML xml
    doc.xpath(xp).map {
      |node| yield node
    }
  end

  it "has all bookmarks on page" do
    get "/"
    info = get_xml_info(last_response.body, '//li/a[1]' ) {
      |node| {
        :title =>node.content,
        :id    =>node.attributes['href'].content[/\d+/].to_i
      }
    }

    bookmarks = app.send(:get_all_bookmarks) # call private method
    # lets compare bookmarks to node info
    bookmarks.each {
      |b| bookmark = info.find { |h| h[:id] == b.id }
          expect(b['title']).to eq(bookmark[:title])
    }
  end

  it "creates a new bookmark" do

    title = Digest('MD5').new.hexdigest(Time.now.to_s)
    post "/bookmarks/new",
      { :url   => "http://testlink.com",
        :title => title
      }
    expect(last_response.status).to be(302)

    get "/"
    info = get_xml_info(last_response.body, '//li/a[1][text()]') {
      |node| { :title => node.content }
    }

    nodeinfo = info.find { |b| b[:title] == title }
    expect(nodeinfo).not_to be_empty
    expect(nodeinfo[:title]).to eq(title)
  end

  # grab most recent bookmark (by id)
  # delete it
  # recheck for it
  it "deletes a bookmark" do
    bookmarks = app.send(:get_all_bookmarks) # call private method
    last_id   = bookmarks.inject(0) do
      |memo,b| memo > b.id ? memo : b.id
    end
    start_size = bookmarks.size
    
    delete "/bookmarks/#{last_id}"
    expect(last_response.status).to be(302)

    get '/'
    # try to find the id
    info = get_xml_info(last_response.body, '//li/a[1]' ) {
      |node| {
        :id    =>node.attributes['href'].content[/\d+/].to_i
      }
    }
    end_size = info.size
    nodes    = info.find { |b| b[:id] == last_id }

    expect(start_size).to be(end_size + 1)
    expect(nodes).to be(nil)
  end

end