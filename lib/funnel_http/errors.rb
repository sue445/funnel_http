# frozen_string_literal: true

module FunnelHttp
  class Error < StandardError; end

  # Aggregates multiple http errors
  class HttpAggregateError < Error
    # Generate error message for [StandardError#initialize]
    #
    # @param error_responses [Array<Hash<Symbol => Object>>]
    #
    # @return [String]
    def self.generate_error_message(error_responses)
      error_responses.map { |res| "#{res[:url]} (#{res[:status_code]} error)" }.join(", ")
    end
  end
end
