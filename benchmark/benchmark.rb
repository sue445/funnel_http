require "benchmark/ips"
require "open-uri"

require "openssl"
require "net/https"

ROOT_DIR = File.expand_path("..", __dir__)

TEST_SERVER_URL = ENV.fetch("TEST_SERVER_URL") { "http://localhost:8080/" }.freeze

REQUEST_COUNT = (ENV.fetch("REQUEST_COUNT") { 100 }).to_i

def sh(command)
  system(command, exception: true)
end

# Build native extension before running benchmark
Dir.chdir(ROOT_DIR) do
  sh "bundle config set --local path 'vendor/bundle'"
  sh "bundle install"
  sh "bundle exec rake clobber compile"
end

require_relative "../lib/funnel_http"

# Suppress Ractor warning
$VERBOSE = nil

sh "go version"

requests = Array.new(REQUEST_COUNT, { method: :get, url: TEST_SERVER_URL })

Ractor.make_shareable OpenSSL::SSL::SSLContext::DEFAULT_PARAMS
Ractor.make_shareable Net::HTTP::SSL_IVNAMES
Ractor.make_shareable Net::HTTP::SSL_ATTRIBUTES
Ractor.make_shareable Net::HTTPResponse::CODE_TO_OBJ

def fetch_server
  # URI.parse(TEST_SERVER_URL).open(open_timeout: 90, read_timeout: 90).read

  # FIXME: Workaround for unavailability of net/http in Ractor
  # c.f. https://osyoyu.com/blog/2025/05/06/005706
  uri = URI.parse(TEST_SERVER_URL)
  http = Net::HTTP.new(uri.host, uri.port)

  if uri.scheme == "https"
    http.use_ssl = true

    # OpenSSL::SSL::SSLContext::DEFAULT_CERT_STORE cannot be shareable, so create an equivalent
    # https://github.com/ruby/openssl/issues/521
    cert_store = OpenSSL::X509::Store.new
    cert_store.set_default_paths
    cert_store.flags = OpenSSL::X509::V_FLAG_CRL_CHECK_ALL
    http.cert_store = cert_store
  end

  # Do not touch Timeout::TIMEOUT_THREAD_MUTEX (Ractor unshareable)
  http.open_timeout = nil

  http.get(uri.path)
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

  x.report("Parallel with Ractor") do
    REQUEST_COUNT.times.map do
      Ractor.new { fetch_server }
    end.each(&:take)
  end

  x.report("Parallel with Fiber") do
    REQUEST_COUNT.times.map do
      Fiber.new { fetch_server }
    end.each(&:resume)
  end

  x.compare!
end
