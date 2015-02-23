
require "date"
require "data_mapper"

class Bookmark
    include DataMapper::Resource

    property :id,         Serial
    property :url,        String, :required => true, :format => :url
    property :title,      String
    property :created_at, Date, :default => Date.today

    # add tag support
    has n, :taggings, :constraint => :destroy
    has n, :tags, :through => :taggings, :order => [:label.asc]

    def tagList
      tags.collect { |tag| tag.label }
    end
end
