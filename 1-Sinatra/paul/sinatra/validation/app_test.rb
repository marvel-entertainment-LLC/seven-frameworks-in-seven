require_relative "app"
require "rspec"
require "rack/test"
require "json"

describe "crud application" do |variable|
	include Rack::Test::Methods

	def app
		Sinatra::Application
	end

	it "sends an error code for an invalid create request" do

		post "/bookmarks", { :url => "test", :title => "Test" }
		expect( last_response.status ).to eq( 400 )

	end

	it "sends a success code for an valid create request" do

		post "/bookmarks", { :url => "http://www.test.com", :title => "Test" }
		expect( last_response.status ).to eq( 201 )

	end

	it "sends an error code for an invalid update request" do

		get "/bookmarks", nil, { "HTTP_ACCEPT" => "application/json" }
		bookmarks = JSON.parse( last_response.body )
		id = bookmarks.first[ 'id' ]

		put "/bookmarks/#{ id }", { :title => "Success", :url => "http://www.foo.com" }
		expect( last_response.status ).to eq( 204 )

		put "/bookmarks/#{ id }", { :title => "Success", :url => "foo" }
		expect( last_response.status ).to eq( 400 )

		put "/bookmarks/-1", { :url => "foo" }
		expect( last_response.status ).to eq( 404 )

	end

	it "binds block parameters by order, not by name" do

		get "/test/duck/quack"
		expect( last_response.body ).to eq( "a duck says quack" )

	end 

	# it "creates a new bookmark" do

	# 	get "/bookmarks"
	# 	bookmarks = JSON.parse( last_response.body )
	# 	last_size = bookmarks.size

	# 	post "/bookmarks", { :url => "http://www.test.com", :title => "Test" }

	# 	expect( last_response.status ).to eq( 201 )
	# 	expect( last_response.body ).to match( "/bookmark|/d+/" )

	# 	get "/bookmarks"
	# 	bookmarks = JSON.parse( last_response.body )
	# 	expect( bookmarks.size ).to eq( last_size + 1 )

	# end

	# it "updates a new bookmark" do

	# 	post "/bookmarks", { :url => "http://www.test.com", :title => "Test Put" }
	# 	bookmark_uri = last_response.body
	# 	id = bookmark_uri.split( "/" ).last

	# 	put "/bookmarks/#{ id }", { :title => "Success" }
	# 	expect( last_response.status ).to eq( 204 )

	# 	get "/bookmarks/#{ id }"
	# 	retrieved_bookmark = JSON.parse( last_response.body )
	# 	expect( retrieved_bookmark[ "title" ] ).to eq( "Success" )


	# end

	# it "deletes a new bookmark" do

	# 	post "/bookmarks", { :url => "http://www.test.com", :title => "Test Delete" }
	# 	bookmark_uri = last_response.body
	# 	id = bookmark_uri.split( "/" ).last

	# 	delete "/bookmarks/#{ id }"
	# 	expect( last_response.status ).to eq( 200 )

	# 	get "/bookmarks/#{ id }"
	# 	expect( last_response.status ).to eq( 404 )


	# end

end