require "sinatra"
require "puma"

class TestServer < Sinatra::Base
  get "/get" do
    content_type "text/plain"
    response["X-Test-Header"] = request.env["X-Test-Header"] if request.env.key?("X-Test-Header")

    "/get"
  end
end

RSpec.shared_examples :test_server do
  before(:all) do
    app = TestServer.new
    @server = Puma::Server.new(app, nil, min_threads: 2, max_threads: 5)
    @server.add_tcp_listener("127.0.0.1", ENV["TEST_SERVER_PORT"])

    @server_thread = Thread.new do
      @server.run
    end

    sleep 1
  end

  after(:all) do
    @server.stop(true)
    @server_thread.kill
  end

  let(:test_server) { "http://localhost:#{ENV["TEST_SERVER_PORT"]}" }
end
