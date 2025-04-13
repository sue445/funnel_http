# frozen_string_literal: true

RSpec.describe FunnelHttp::HttpAggregateError do
  describe ".generate_error_message" do
    subject { FunnelHttp::HttpAggregateError.generate_error_message(error_responses) }

    let(:error_responses) do
      [
        {
          url: "http://example.com/not_found",
          status_code: 404,
          body: "",
          header: {},
        },
        {
          url: "http://example.com/internal_error",
          status_code: 502,
          body: "",
          header: {},
        },
      ]
    end

    it { should eq "http://example.com/not_found (404 error), http://example.com/internal_error (502 error)" }
  end
end
