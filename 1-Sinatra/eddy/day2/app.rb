
require "sinatra"
require "data_mapper"
require_relative "bookmark"
require "dm-serializer"
require "nokogiri"

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/bookmarks.db")
DataMapper.finalize.auto_upgrade!

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

def get_all_bookmarks
  Bookmark.all(:order => :title)
end

get "/" do
  content_type :html
  @bookmarks = get_all_bookmarks
  nokogiri :bookmark_list
end

get "/bookmark/new" do
  content_type :html
  @sinatra = self
  nokogiri :bookmark_new
end

get "/bookmarks/:id" do
  @sinatra = self
  id = params[:id]
  @bookmark = Bookmark.get(id)
  content_type :html
  nokogiri :bookmark_edit
end

post "/bookmarks/:id" do
  input = params.slice "url", "title"
  bookmark = Bookmark.create input
  # Created
  [201, "/bookmarks/#{bookmark['id']}"]
end

put "/bookmarks/:id" do
  @sinatra = self
  id = params[:id]
  @bookmark = Bookmark.get(id)
  input = params.slice "url", "title"
  bookmark.update input
  to '/'
end

delete "/bookmarks/:id" do
  @sinatra = self
  id = params[:id]
  bookmark = Bookmark.get(id)
  bookmark.destroy
  to '/'
end
