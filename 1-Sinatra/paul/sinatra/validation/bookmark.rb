require "data_mapper"

class Bookmark

	include DataMapper::Resource

	property :id, Serial
	property :url, String, :required => true, :format => :url
	property :title, String, :required => true

end