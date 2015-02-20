require "sinatra"
require "data_mapper"
require_relative "bookmark"
require "dm-serializer"

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/bookmarks.db")
DataMapper.finalize.auto_upgrade!


def get_all_bookmarks
  Bookmark.all(:order => :title)
end

get "/bookmarks" do
  content_type :json
  get_all_bookmarks.to_json
end

post "/bookmarks" do
  input = params.slice "url", "title"
  bookmark = Bookmark.create input
  # Created
  [201, "/bookmarks/#{bookmark['id']}"]
end 

get "/bookmarks/:id" do
  id = params[:id]
  bookmark = Bookmark.get(id)
  content_type :json
  bookmark.to_json
end

put "/bookmarks/:id" do
  id = params[:id]
  bookmark = Bookmark.get(id)
  input = params.slice "url", "title"
  bookmark.update input
  204 # No Content
end

delete "/bookmarks/:id" do
  id = params[:id]
  bookmark = Bookmark.get(id)
  bookmark.destroy
  200 # OK
end

class Hash
  def slice(*whitelist)
    whitelist.inject({}) {|result, key| result.merge(key => self[key])}
  end
end
