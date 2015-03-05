require "sinatra"
require "data_mapper"
require_relative "bookmark"
require "dm-serializer"
require "sinatra/respond_with"
require "haml"

set :port, 9000

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/bookmarks.db")
DataMapper.finalize.auto_upgrade!

get "/bookmarks/:id" do
  id = params[:id]
  @bookmark = Bookmark.get(id)
  respond_with :bookmark_form_edit, @bookmark
end

put "/bookmarks/:id" do
  id = params[:id]
  bookmark = Bookmark.get(id)
  input = params.slice "url", "title"
  bookmark.update input
  respond_to do |f|
    f.html { redirect "/" }
    f.json { 204 }
  end
end

delete "/bookmarks/:id" do
  id = params[:id]
  bookmark = Bookmark.get(id)
  bookmark.destroy
  respond_to do |f|
    f.html { redirect "/" }
    f.json { 200 }
  end
end

def get_all_bookmarks
  Bookmark.all(:order => :title)
end

get "/bookmarks" do
  @bookmarks = get_all_bookmarks
  respond_with :bookmark_list, @bookmarks
end

post "/bookmarks" do
  input = params.slice "url", "title"
  bookmark = Bookmark.create input
  respond_to do |f|
    f.html { redirect "/" }
    f.json { [201, "/bookmarks/#{bookmark['id']}"] }
  end
end

get "/" do
  @bookmarks = get_all_bookmarks
  haml :bookmark_list
end

get "/bookmark/new" do
  haml :bookmark_form_new
end

class Hash
  def slice(*whitelist)
    whitelist.inject({}) {|result, key| result.merge(key => self[key])}
  end
end