RSpec.shared_examples :test_server do
  before(:all) do
    dummy_server_dir = spec_dir.join("support", "server")
    @server_pid = spawn("bundle exec puma --bind tcp://0.0.0.0:#{ENV["TEST_SERVER_PORT"]} #{dummy_server_dir.join("dummy_app.rb")}")
    sleep 1
    puts "Test server started with PID #{@server_pid}"
  end

  after(:all) do
    if @server_pid
      puts "Stopping test server with PID #{@server_pid}"
      Process.kill("TERM", @server_pid)
      Process.wait(@server_pid)
    end
  end

  let(:test_server) { "http://localhost:#{ENV["TEST_SERVER_PORT"]}" }
end
