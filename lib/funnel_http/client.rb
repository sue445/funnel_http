# frozen_string_literal: true

module FunnelHttp
  class Client
    # perform HTTP requests in parallel
    #
    # @param requests [Array<Hash{String => String}>] `Array` of following `Hash`
    # @option requests :method [String, Symbol] Request method (e.g. `:get`, `"POST"`)
    # @option requests :url [String] Request url
    # @option requests :header [Hash{String, => String, Array<String>}] Request header
    #
    # @return [Array<Hash<Symbol, Object>>] `Array` of following `Hash`
    # @return [Integer] `:status_code`
    # @return [String] `:body` Response body
    # @return [Hash{String, => Array<String>}] `:header` Response header
    def perform(requests)
      FunnelHttp.run_requests(requests)
    end
  end
end
