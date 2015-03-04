require "sinatra"
get "/hello" do
	"Hello, Sinatra"
end
get "/echo/:foo" do
	"echoing #{params[:foo]}"
end