require "sinatra"
require "data_mapper"
require "dm-serializer"
require_relative "bookmark"

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/bookmarks.db")
DataMapper.finalize.auto_upgrade!

class Hash
    def slice(*whitelist)
        whitelist.inject({}) {|result, key| result.merge(key => self[key])}
    end
end

def get_all_bookmarks
    Bookmark.all(:order => :title)
end

get "/bookmarks" do
    content_type :json
    get_all_bookmarks.to_json
end

get "/bookmarks/:id" do
    id = params[:id]
    bookmark = Bookmark.get(id)
    content_type :json
    unless bookmark.nil? 
        bookmark.to_json
    else
        [404, {}]
    end
end

post "/bookmarks" do
    input = params.slice "url", "title"
    bookmark = Bookmark.create input
    # Created
    [201, "/bookmarks/#{bookmark['id']}"]
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