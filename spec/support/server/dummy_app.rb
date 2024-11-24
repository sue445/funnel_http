require "sinatra"
require "puma"

class DummyApp < Sinatra::Base
  get "/get" do
    content_type "text/plain"

    http_headers = request.env.select { |k, v| k.start_with?("HTTP_") }
    response["X-Request-Headers"] = http_headers.to_s

    "/get"
  end
end
