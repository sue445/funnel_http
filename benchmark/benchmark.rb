require "benchmark/ips"

ENV["TEST_SERVER_PORT"] ||= "8080"

ROOT_DIR = File.expand_path("..", __dir__)

TEST_SERVER = "http://localhost:#{ENV["TEST_SERVER_PORT"]}"

REQUEST_COUNT = 10

# Build native extension before running benchmark
Dir.chdir(ROOT_DIR) do
  system("bundle config set --local path 'vendor/bundle'", exception: true)
  system("bundle install", exception: true)
  system("bundle exec rake", exception: true)
end

require_relative "../lib/funnel_http"

# Suppress Ractor warning
$VERBOSE = nil

system("go version", exception: true)

def with_dummy_server
  @server_pid = spawn("bundle exec puma --bind tcp://0.0.0.0:#{ENV["TEST_SERVER_PORT"]} --threads 16:16 #{File.join(ROOT_DIR, "spec", "support", "server", "dummy_app.rb")}")
  sleep 1
  puts "Test server started with PID #{@server_pid}"

  yield

ensure
  if @server_pid
    puts "Stopping test server with PID #{@server_pid}"
    Process.kill("TERM", @server_pid)
    Process.wait(@server_pid)
  end
end

requests = Array.new(REQUEST_COUNT, { method: :get, url: "#{TEST_SERVER}/get" })

with_dummy_server do
  Benchmark.ips do |x|
    x.report("FunnelHttp::Client#perform") do
      FunnelHttp::Client.new.perform(requests)
    end

    x.compare!
  end
end
