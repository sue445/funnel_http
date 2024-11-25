# frozen_string_literal: true

module FunnelHttp
  class Client
    # perform HTTP requests in parallel
    #
    # @overload perform(requests)
    #   @param requests [Array<Hash{String => String}>] `Array` of following `Hash`
    #   @option requests :method [String, Symbol] Request method (e.g. `:get`, `"POST"`)
    #   @option requests :url [String] Request url
    #   @option requests :header [Hash{String, => String, Array<String>}] Request header
    #
    # @overload perform(request)
    #   @param request [Hash{String => String}]
    #   @option request :method [String, Symbol] Request method (e.g. `:get`, `"POST"`)
    #   @option request :url [String] Request url
    #   @option request :header [Hash{String, => String, Array<String>}] Request header
    #
    # @return [Array<Hash<Symbol, Object>>] `Array` of following `Hash`
    # @return [Integer] `:status_code`
    # @return [String] `:body` Response body
    # @return [Hash{String, => Array<String>}] `:header` Response header
    def perform(requests)
      FunnelHttp.run_requests(Client.normalize_requests(requests))
    end

    # @overload normalize_requests(arg)
    #   @param requests [Array<Hash{String => String}>] `Array` of following `Hash`
    #   @option requests :method [String, Symbol] Request method (e.g. `:get`, `"POST"`)
    #   @option requests :url [String] Request url
    #   @option requests :header [Hash{String, => String, Array<String>}] Request header
    #
    # @overload normalize_requests(arg)
    #   @param request [Hash{String => String}]
    #   @option request :method [String, Symbol] Request method (e.g. `:get`, `"POST"`)
    #   @option request :url [String] Request url
    #   @option request :header [Hash{String, => String, Array<String>}] Request header
    #
    # @return [Array<Hash{String => String}>] `Array` of following `Hash`
    # @return [String] `:method` Request method (e.g. `"POST"`)
    # @return [String] `:url` Request url
    # @return [Hash{String, => Array<String>}] `:header` Request header
    def self.normalize_requests(arg)
      requests =
        case arg
        when Array
          arg
        when Hash
          [arg]
        else
          raise ArgumentError, "#{arg} must be Array or Hash"
        end

      requests.map do |request|
        raise ArgumentError, "#{arg} contains something other than Hash" unless request.is_a?(Hash)

        raise ArgumentError, "#{arg} key does not contain all :method and :url" if !request.key?(:method) || !request.key?(:url)

        {
          url: request[:url].to_s,
          method: request[:method].to_s.upcase,
          header: normalize_header(request[:header]),
        }
      end
    end

    # @param header [Hash{String, => String, Array<String>}, nil] Request header
    # @return [Hash{String, => Array<String>}] Request header
    def self.normalize_header(header)
      return {} unless header

      header.each_with_object({}) do |(k, v), hash|
        # FIXME: Fails `steep check` when use Array(v)...
        # hash[k] = Array(v)
        hash[k] = v.is_a?(Array) ? v : Array(v)
      end
    end
    private_class_method :normalize_header
  end
end
