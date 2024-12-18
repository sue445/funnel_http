require "benchmark/ips"
require "open-uri"
require "parallel"
require "etc"

ROOT_DIR = File.expand_path("..", __dir__)

TEST_SERVER_URL = ENV.fetch("TEST_SERVER_URL") { "http://localhost:8080/" }

REQUEST_COUNT = 100

BENCHMARK_CONCURRENCY = ENV.fetch("BENCHMARK_CONCURRENCY") { 4 }

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
  x.config(warmup: 1, time: 2)

  x.report("FunnelHttp::Client#perform") do
    FunnelHttp::Client.new.perform(requests)
  end

  x.report("Parallel with #{BENCHMARK_CONCURRENCY} processes") do
    Parallel.each(requests, in_processes: BENCHMARK_CONCURRENCY) do
      fetch_server
    end
  end

  x.report("Parallel with #{BENCHMARK_CONCURRENCY} threads") do
    Parallel.each(requests, in_threads: BENCHMARK_CONCURRENCY) do
      fetch_server
    end
  end

  # FIXME: open-uri doesn't work in Ractor
  # x.report("Parallel with Ractor") do
  #   REQUEST_COUNT.times.map do
  #     Ractor.new { URI.parse("http://localhost:8080/").read }
  #   end.each(&:take)
  # end

  x.compare!
end
