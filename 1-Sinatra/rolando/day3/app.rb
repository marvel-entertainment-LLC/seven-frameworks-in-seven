#---
# Excerpted from "Seven Web Frameworks in Seven Weeks",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/7web for more book information.
#---
require "sinatra"
require "data_mapper"
require_relative "bookmark"
require_relative "tagging"
require_relative "tag"
require "dm-serializer"
require "sinatra/respond_with"

set :port, 9000

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/bookmarks.db")
#DataMapper.finalize.auto_migrate!
DataMapper.finalize.auto_upgrade!

before %r{/bookmarks/(\d+)} do |id|
  # ...
  @bookmark = Bookmark.get(id)

  if !@bookmark
    halt 404, "bookmark #{id} not found"
  end
end

with_tagList = {:methods => [:tagList]}

get %r{/bookmarks/\d+} do
  respond_to do |f|
    f.html { erb :bookmark_form_edit }
    f.json { @bookmark.to_json with_tagList }
  end
end

put %r{/bookmarks/\d+} do
  # ...
  input = params.slice "url", "title"
  if @bookmark.update input
    add_tags(@bookmark)
    204 # No Content
  else
    400 # Bad Request
  end
end

delete %r{/bookmarks/\d+} do
  # ...
  if @bookmark.destroy
    respond_to do |f|
      f.html { redirect "/" }
      f.json { 200 } # OK
    end
  else
    500 # Internal Server Error
  end
end

get "/bookmarks/*" do
  tags = params[:splat].first.split "/"
  @bookmarks = Bookmark.all
  tags.each do |tag|
    @bookmarks = @bookmarks.all({:taggings => {:tag => {:label => tag}}})
  end
  # bookmarks.to_json with_tagList
  respond_to do |f|
    f.html { erb :bookmark_list}
    f.json { @bookmarks.to_json with_tagList }
  end
end

def get_all_bookmarks
  Bookmark.all(:order => :title)
end

get "/bookmarks" do
  @bookmarks = get_all_bookmarks
  respond_to do |f|
    f.html { erb :bookmark_list}
    f.json { @bookmarks.to_json with_tagList }
  end
end

post "/bookmarks" do
  input = params.slice "url", "title"
  bookmark = Bookmark.new input
  if bookmark.save
    add_tags(bookmark)

    # Created
    [201, "/bookmarks/#{bookmark['id']}"]
  else
    400 # Bad Request
  end
end

helpers do
  def add_tags(bookmark)
    print params["tagsAsString"]
    labels = (params["tagsAsString"] || "").split(",").map(&:strip)
    # more code to come

    existing_labels = []
    bookmark.taggings.each do |tagging|
      if labels.include? tagging.tag.label
        existing_labels.push tagging.tag.label
      else
        tagging.destroy
      end
    end

    (labels - existing_labels).each do |label|
      tag = {:label => label}
      existing = Tag.first tag
      if !existing
        existing = Tag.create tag
      end
      Tagging.create :tag => existing, :bookmark => bookmark
    end
  end
end

get "/" do
  @bookmarks = get_all_bookmarks
  erb :bookmark_list
end

get "/bookmark/new" do
  erb :bookmark_form_new
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

class Hash
  def slice(*whitelist)
    whitelist.inject({}) {|result, key| result.merge(key => self[key])}
  end
end