# frozen_string_literal: true

RSpec.describe FunnelHttp::Client do
  let(:client) { FunnelHttp::Client.new }

  describe "#perform" do
    include_context :test_server

    subject(:responses) { client.perform(requests) }

    context "simple case" do
      let(:requests) do
        [
          {
            method: "GET",
            url: "#{test_server}/get",
            header: {"X-Test-Header" => ["a", "b"]}
          },
          {
            method: "GET",
            url: "#{test_server}/get",
            header: {"X-Test-Header" => ["c", "d"]}
          },
        ]
      end

      its(:count) { should eq 2 }

      describe "[0]" do
        subject { responses[0] }

        its([:status_code]) { should eq 200 }
        its([:body]) { should eq "/get" }
        its([:header]) { should include("Content-Type" => ["text/plain;charset=utf-8"]) }
        its([:header]) { should include("X-Request-Headers" => [include('"HTTP_X_TEST_HEADER"=>"a, b"')]) }
      end

      describe "[1]" do
        subject { responses[1] }

        its([:status_code]) { should eq 200 }
        its([:body]) { should eq "/get" }
        its([:header]) { should include("Content-Type" => ["text/plain;charset=utf-8"]) }
        its([:header]) { should include("X-Request-Headers" => [include('"HTTP_X_TEST_HEADER"=>"c, d"')]) }
      end
    end
  end
end
