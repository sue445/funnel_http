# frozen_string_literal: true

require_relative "funnel_http/version"
require_relative "funnel_http/client"
require_relative "funnel_http/ext"
require_relative "funnel_http/errors"
require_relative "funnel_http/funnel_http"

module FunnelHttp
  USER_AGENT = "funnel_http/#{FunnelHttp::VERSION} (+https://github.com/sue445/funnel_http)"

  # Your code goes here...
end
