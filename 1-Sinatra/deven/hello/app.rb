# In order to run from host machine via VM private ip
# (e.g. 192.168.77.10:4567/hello), run this script
# via the following command:
# ~$ ruby app.rb -o 0.0.0.0

require "sinatra"
get "/hello" do
	"Hello, Sinatra"
end