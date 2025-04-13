# frozen_string_literal: true

module FunnelHttp
  class Error < StandardError; end

  # Aggregates multiple http errors
  class HttpAggregateError < Error
    # @!attribute [r] error_responses
    #   @return [Array<Hash<Symbol => Object>>] `Array` of following `Hash`
    #   @return [String] `:url` Request url
    #   @return [Integer] `:status_code`
    #   @return [String] `:body` Response body
    #   @return [Hash{String => Array<String>}] `:header` Response header
    attr_reader :error_responses

    # @param error_responses [Array<Hash<Symbol => Object>>]
    def initialize(error_responses)
      @error_responses = error_responses
      super(HttpAggregateError.generate_error_message(error_responses))
    end

    # Generate error message for `StandardError#initialize`
    #
    # @param error_responses [Array<Hash<Symbol => Object>>]
    #
    # @return [String]
    def self.generate_error_message(error_responses)
      error_responses.map { |res| "#{res[:url]} (#{res[:status_code]} error)" }.join(", ")
    end
  end
end
