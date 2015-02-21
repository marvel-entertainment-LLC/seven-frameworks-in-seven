
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

before do
  @sinatra = self
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
  nokogiri :bookmark_new
end
post "/bookmarks/new" do
  input = params.slice "url", "title"
  Bookmark.create input
  redirect to("/")
end

get "/bookmarks/:id" do
  id = params[:id]
  @bookmark = Bookmark.get(id)
  content_type :html
  nokogiri :bookmark_edit
end

put "/bookmarks/:id" do
  id = params[:id]
  bookmark = Bookmark.get(id)
  input = params.slice "url", "title"
  bookmark.update input
  redirect to('/')
end

delete "/bookmarks/:id" do
  id = params[:id]
  bookmark = Bookmark.get(id)
  bookmark.destroy
  redirect to('/')
end

class Hash
  def slice(*whitelist)
    whitelist.inject({}) {|result, key| result.merge(key => self[key])}
  end
end