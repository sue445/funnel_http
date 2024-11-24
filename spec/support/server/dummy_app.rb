require "sinatra"
require "puma"

class DummyApp < Sinatra::Base
  get "/get" do
    content_type "text/plain"
    response["X-Test-Header"] = request.env["X-Test-Header"] if request.env.key?("X-Test-Header")

    "/get"
  end
end
