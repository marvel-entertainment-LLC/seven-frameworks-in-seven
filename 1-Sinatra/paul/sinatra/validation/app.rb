require "sinatra"
require "data_mapper"

require_relative "bookmark"

DataMapper::setup( :default, "sqlite3://#{Dir.pwd}/bookmarks.db")
DataMapper.finalize.auto_upgrade!

require "dm-serializer"
require "sinatra/respond_with"

before "/bookmarks/:id" do |id|

	@bookmark= Bookmark.get( id )
	
	if !@bookmark

		halt 404, "bookmark #{id} not found"

	end

end

get "/" do

	@bookmarks = get_all_bookmarks
	erb :bookmark_list

end

get "/bookmarks" do 

	@bookmarks = get_all_bookmarks
	respond_with :bookmark_list, @bookmarks
	# get_all_bookmarks.to_json

end

get "/bookmarks/new" do

	erb :bookmark_form_new

end

get "/bookmarks/:id" do

	id = params[ :id ]
	bookmark =  Bookmark.get( id )
	content_type :json
	bookmark.to_json

end

post "/bookmarks" do

	input = params.slice "url", "title"
	bookmark = Bookmark.create input
	if bookmark.save
		
		# Created
		[ 201, "/bookmarks/#{ bookmark[ 'id' ] }"]

	else

		400 #bad request
		
	end

end

put "/bookmarks/:id" do

	id = params[ :id ]
	bookmark = Bookmark.get( id )

	input = params.slice "url", "title"
	if bookmark.update input
	
		204 #no content

	else

		400 #bad request

	end 

end

get "/test/:one/:two" do |creature, sound|

	"a #{ creature } says #{ sound }"

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
