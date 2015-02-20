require "data_mapper"
require "dm-timestamps"

class Bookmark
  include DataMapper::Resource

  property :id, Serial
  property :url, String
  property :title, String
  property :created_at, DateTime
end
