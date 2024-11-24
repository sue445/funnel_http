# frozen_string_literal: true

RSpec.describe FunnelHttp::Client do
  let(:client) { FunnelHttp::Client.new }

  describe "#perform" do
    include_context :test_server

    subject(:responses) { client.perform(requests) }

    let(:requests) do
      [
        {
          method: :get,
          url: "#{test_server}/get",
          header: {"X-Test-Header" => ["a", "b"]}
        },
        {
          method: :get,
          url: "#{test_server}/get",
          header: {"X-Test-Header" => ["c", "d"]}
        },
      ]
    end

    its(:count) { should eq 2 }

    describe "[0]" do
      subject { responses[0] }

      let(:response_header) do
        {
          "Content-Type" => "text/plain",
          "X-Test-Header" => ["a", "b"],
        }
      end

      its(:status_code) { should eq 200 }
      its(:body) { should eq "/get" }
      its(:header) { should eq response_header }
    end

    describe "[1]" do
      subject { responses[1] }

      let(:response_header) do
        {
          "Content-Type" => "text/plain",
          "X-Test-Header" => ["c", "d"],
        }
      end

      its(:status_code) { should eq 200 }
      its(:body) { should eq "/get" }
      its(:header) { should eq response_header }
    end
  end
end
