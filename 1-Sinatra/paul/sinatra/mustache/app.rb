require "sinatra"
require "data_mapper"
require "dm-serializer"
require "sinatra/respond_with"
require "mustache"

require_relative "bookmark"

DataMapper::setup( :default, "sqlite3://#{Dir.pwd}/bookmarks.db")
DataMapper.finalize.auto_upgrade!

get "/" do

	@bookmarks = get_all_bookmarks
	mustache :bookmark_list

end

get "/bookmarks" do 

	@bookmarks = get_all_bookmarks
	respond_with :bookmark_list, @bookmarks

end

get "/bookmarks/new" do

	mustache :bookmark_form_new

end

get "/bookmarks/:id" do

	id = params[ :id ]
	bookmark =  Bookmark.get( id )
	if bookmark.nil?
		halt 404
	end
	content_type :json
	bookmark.to_json

end

post "/bookmarks" do

	input = params.slice "url", "title"
	bookmark = Bookmark.create input
	# Created
	[ 201, "/bookmarks/#{ bookmark[ 'id' ] }"]

end

put "/bookmarks/:id" do

	id = params[ :id ]
	bookmark = Bookmark.get( id )
	input = params.slice "url", "title"
	bookmark.update input
	#no content
	204 

end

delete "/bookmarks/:id" do

	id = params[ :id ]
	bookmark = Bookmark.get( id )
	bookmark.destroy
	200

end

class Hash

	def slice( *whitelist )

		whitelist.inject({}) { | result, key | result.merge( key => self[ key ] ) }

	end

end

helpers do 

	def escape( text )

		Rack::Utils.escape_html( text )

	end 
	
	def get_all_bookmarks

		Bookmark.all(:order => :title)

	end
end
