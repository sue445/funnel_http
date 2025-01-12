# frozen_string_literal: true

module FunnelHttp
  class Client
    # @!attribute default_request_header
    #   @return [Hash{String => String, Array<String>}]
    attr_accessor :default_request_header

    # @param default_request_header [Hash{String => String, Array<String>}]
    def initialize(default_request_header: {})
      @default_request_header = {"User-Agent" => USER_AGENT}.merge(default_request_header)
    end

    # Add header to {default_request_header}
    # @param name [String] Header name
    # @param value [String, Array<String>] Header value
    #
    # @return [Hash{String => String, Array<String>}] {default_request_header} after adding header
    def add_default_request_header(name, value)
      default_request_header.merge!(name => value)
    end

    # perform HTTP requests in parallel
    #
    # @overload perform(requests)
    #   @param requests [Array<Hash{Symbol => Object}>] `Array` of following `Hash`
    #   @option requests :method [String, Symbol] **[required]** Request method (e.g. `:get`, `"POST"`)
    #   @option requests :url [String] **[required]** Request url
    #   @option requests :header [Hash{String => String, Array<String>}, nil] Request header
    #   @option requests :body [String, nil] Request body
    #
    # @overload perform(request)
    #   @param request [Hash{Symbol => Object}]
    #   @option request :method [String, Symbol] **[required]** Request method (e.g. `:get`, `"POST"`)
    #   @option request :url [String] **[required]** Request url
    #   @option request :header [Hash{String => String, Array<String>}, nil] Request header
    #   @option request :body [String, nil] Request body
    #
    # @return [Array<Hash<Symbol => Object>>] `Array` of following `Hash`
    # @return [Integer] `:status_code`
    # @return [String] `:body` Response body
    # @return [Hash{String => Array<String>}] `:header` Response header
    def perform(requests)
      ext_client.run_requests(normalize_requests(requests))
    end

    # @overload normalize_requests(requests)
    #   @param requests [Array<Hash{Symbol => Object}>] `Array` of following `Hash`
    #   @option requests :method [String, Symbol]  **[required]** Request method (e.g. `:get`, `"POST"`)
    #   @option requests :url [String] **[required]** Request url
    #   @option requests :header [Hash{String => String, Array<String>}, nil] Request header
    #
    # @overload normalize_requests(request)
    #   @param request [Hash{Symbol => Object}]
    #   @option request :method [String, Symbol] **[required]** Request method (e.g. `:get`, `"POST"`)
    #   @option request :url [String] **[required]** Request url
    #   @option request :header [Hash{String => String, Array<String>}, nil] Request header
    #
    # @return [Array<Hash{Symbol => Object}>] `Array` of following `Hash`
    # @return [String] `:method` Request method (e.g. `"POST"`)
    # @return [String] `:url` Request url
    # @return [Hash{String => Array<String>}] `:header` Request header
    def normalize_requests(arg)
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
          body: request[:body].freeze,
        }
      end
    end

    private

    # @param header [Hash{String => String, Array<String>}, nil] Request header
    # @return [Hash{String => Array<String>}] Request header
    def normalize_header(header)
      full_header =
        if header
          default_request_header.dup.merge(header)
        else
          default_request_header.dup
        end

      # Workaround for Ruby::UnannotatedEmptyCollection on steep 1.9.0+
      result = {} #: strict_header

      full_header.each_with_object(result) do |(k, v), hash|
        # FIXME: Fails `steep check` when use Array(v)...
        # hash[k] = Array(v)
        hash[k] = v.is_a?(Array) ? v : Array(v)
      end
    end

    # @return [FunnelHttp::Ext::Client]
    def ext_client
      @ext_client ||= FunnelHttp::Ext::Client.new
    end
  end
end
