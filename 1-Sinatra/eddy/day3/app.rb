require "sinatra"
require "sinatra/respond_with"
require "data_mapper"
require_relative "bookmark"
require_relative "tagging"
require_relative "tag"
require "dm-serializer"
require "haml"

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/bookmarks.db")
DataMapper.finalize.auto_upgrade!

layout :layout

before %r{/bookmarks/(\d+)} do |id|
  @bookmark = Bookmark.get(id)

  if !@bookmark
    halt 404, "bookmark #{id} not found"
  end
end

with_tagList = {:methods => [:tagList]}

get %r{/bookmarks/\d+} do
  #content_type :json

  #@bookmark.to_json with_tagList
  respond_with :bookmark_edit
end

put %r{/bookmarks/\d+} do
  input = params.slice "url", "title"
  if @bookmark.update input
    add_tags(@bookmark)
    204 # No Content
  else
    400 # Bad Request
  end
end

delete %r{/bookmarks/\d+} do
  if @bookmark.destroy
    200 # OK
  else
    500 # Internal Server Error
  end
end

get "/bookmarks/*" do
  tags = params[:splat].first.split "/"
  bookmarks = Bookmark.all
  tags.each do |tag|
    bookmarks = bookmarks.all({:taggings => {:tag => {:label => tag}}})
  end
  respond_with :bookmark_list
  #bookmarks.to_json with_tagList
end

def get_all_bookmarks
  Bookmark.all(:order => :title)
end

get "/bookmarks" do
  #content_type :json
  #get_all_bookmarks.to_json with_tagList
  @bookmarks = get_all_bookmarks
  new_bookmark = !params['new'].nil?
  respond_with :bookmark_new  if new_bookmark
  respond_with :bookmark_list unless new_bookmark
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
    labels = (params["tagsAsString"] || "").split(",").map(&:strip)

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
      existing = Tag.create tag unless existing
      Tagging.create :tag => existing, :bookmark => bookmark
    end
  end
end

class Hash
  def slice(*whitelist)
    whitelist.inject({}) {|result, key| result.merge(key => self[key])}
  end
end