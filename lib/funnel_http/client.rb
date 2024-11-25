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
      FunnelHttp.run_requests(requests)
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

        request = request.transform_keys(&:to_sym)
        raise ArgumentError, "#{arg} key does not contain all :method and :url" unless %i(method url).all? { |key| request.key?(key) }

        request[:method] = request[:method].to_s.upcase

        request[:header] ||= {}
        request[:header] =
          request[:header].each_with_object({}) do |(k, v), hash|
            hash[k] = Array(v)
          end

        request
      end
    end
  end
end
