require "data_mapper"

class Bookmark

	include DataMapper::Resource

	property :id, Serial
	property :url, String, :required => true, :format => :url
	property :title, String, :required => true

	#tags added...
	has n, :taggings, :constraint => :destroy
	has n, :tags, :through => :taggings, :order => [ :label.asc ]

	def taglist

		tags.collect do |tag|

			tag.label

		end

	end

end