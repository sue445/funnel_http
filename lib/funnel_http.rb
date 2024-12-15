# frozen_string_literal: true

require_relative "funnel_http/version"
require_relative "funnel_http/client"
require_relative "funnel_http/funnel_http"

module FunnelHttp
  class Error < StandardError; end

  USER_AGENT = "funnel_http/#{FunnelHttp::VERSION} (+https://github.com/sue445/funnel_http)"

  # Your code goes here...
end
