require "sinatra"
require "data_mapper"
require_relative "bookmark"

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/bookmarks.db")
DataMapper.finalize.auto_upgrade!

require "dm-serializer"
def get_all_bookmarks
  Bookmark.all(:order => :title)
end
def get_all_by_date
  Bookmark.all(:order => :created_at)
end

get "/bookmarks" do
  content_type :json
  if params[:sort] == "date"
  	get_all_by_date.to_json
  else
  	get_all_bookmarks.to_json
  end
end

get "/bookmarks-date" do
  content_type :json
  get_all_by_date.to_json
end

post "/bookmarks" do
  input = params.slice "url", "title"
  input[:created_at] = Time.now
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
  200 # OK end
end

class Hash
  def slice(*whitelist)
  	whitelist.inject({}) {|result, key| result.merge(key => self[key])}
  end
end