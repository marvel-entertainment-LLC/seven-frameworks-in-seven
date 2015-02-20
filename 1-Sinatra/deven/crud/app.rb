require "sinatra"
require "data_mapper"
require_relative "bookmark"
require "dm-serializer"

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/bookmarks.db")
DataMapper.finalize.auto_upgrade!


def get_all_bookmarks(options)
  order_by = options.fetch("order_by", "title")
  order_dir = options.fetch("order_dir", "asc")

  # I dunno why, but it works...
  # http://stackoverflow.com/a/5383727
  sort = DataMapper::Query::Operator.new(order_by, order_dir)
  Bookmark.all(:order => [sort])
end

get "/bookmarks" do
  options = {}
  if params[:orderby]
    order_by = params[:orderby].partition(" ")
    options["order_by"] = order_by.first
    options["order_dir"] = (order_by.last if ["asc", "desc"].include?(order_by.last)) || ("asc")
  end

  content_type :json
  get_all_bookmarks(options).to_json
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
