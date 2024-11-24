class TestServer < Sinatra::Base
  get "/get" do
    content_type "text/plain"
    response["X-Test-Header"] = request.env["X-Test-Header"] if request.env.key?("X-Test-Header")

    "/get"
  end
end

RSpec.shared_examples :test_server do
  before(:all) do
    @server_thread = Thread.new do
      TestServer.run!(port: ENV["TEST_SERVER_PORT"])
    end

    sleep 1
  end

  after(:all) do
    @server_thread.kill
  end

  let(:test_server) { "http://localhost:#{ENV["TEST_SERVER_PORT"]}" }
end
