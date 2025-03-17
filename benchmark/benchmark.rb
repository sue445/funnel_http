require "benchmark/ips"
require "open-uri"

ROOT_DIR = File.expand_path("..", __dir__)

TEST_SERVER_URL = ENV.fetch("TEST_SERVER_URL") { "http://localhost:8080/" }

REQUEST_COUNT = (ENV.fetch("REQUEST_COUNT") { 100 }).to_i

# Build native extension before running benchmark
Dir.chdir(ROOT_DIR) do
  system("bundle config set --local path 'vendor/bundle'", exception: true)
  system("bundle install", exception: true)
  system("bundle exec rake clobber compile", exception: true)
end

require_relative "../lib/funnel_http"

# Suppress Ractor warning
$VERBOSE = nil

system("go version", exception: true)

requests = Array.new(REQUEST_COUNT, { method: :get, url: TEST_SERVER_URL })

def fetch_server
  URI.parse(TEST_SERVER_URL).open(open_timeout: 90, read_timeout: 90).read
end

Benchmark.ips do |x|
  x.config(warmup: 2, time: 5)

  x.report("sequential") do
    REQUEST_COUNT.times do
      fetch_server
    end
  end

  x.report("FunnelHttp::Client#perform") do
    FunnelHttp::Client.new.perform(requests)
  end

  # FIXME: open-uri doesn't work in Ractor
  # x.report("Parallel with Ractor") do
  #   REQUEST_COUNT.times.map do
  #     Ractor.new { URI.parse("http://localhost:8080/").read }
  #   end.each(&:take)
  # end

  x.report("Parallel with Fiber") do
    REQUEST_COUNT.times.map do
      Fiber.new { fetch_server }
    end.each(&:resume)
  end

  x.compare!
end
