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

        its([:url]) { should eq "#{test_server}/get" }
        its([:status_code]) { should eq 200 }
        its([:body]) { should eq "/get" }
        its([:header]) { should include("Content-Type" => ["text/plain;charset=utf-8"]) }
        its([:header]) { should include("X-Request-Headers" => [include("HTTP_X_TEST_HEADER=a, b")]) }
        its([:header]) { should include("X-Request-Headers" => [include("HTTP_USER_AGENT=#{FunnelHttp::USER_AGENT}")]) }
      end

      describe "[1]" do
        subject { responses[1] }

        its([:url]) { should eq "#{test_server}/get" }
        its([:status_code]) { should eq 200 }
        its([:body]) { should eq "/get" }
        its([:header]) { should include("Content-Type" => ["text/plain;charset=utf-8"]) }
        its([:header]) { should include("X-Request-Headers" => [include("HTTP_X_TEST_HEADER=c, d")]) }
        its([:header]) { should include("X-Request-Headers" => [include("HTTP_USER_AGENT=#{FunnelHttp::USER_AGENT}")]) }
      end
    end

    context "with symbol method" do
      let(:requests) do
        [
          {
            method: :get,
            url: "#{test_server}/get",
            header: {"X-Test-Header" => ["a", "b"]}
          },
        ]
      end

      its(:count) { should eq 1 }

      describe "[0]" do
        subject { responses[0] }

        its([:url]) { should eq "#{test_server}/get" }
        its([:status_code]) { should eq 200 }
        its([:body]) { should eq "/get" }
        its([:header]) { should include("Content-Type" => ["text/plain;charset=utf-8"]) }
        its([:header]) { should include("X-Request-Headers" => [include("HTTP_X_TEST_HEADER=a, b")]) }
        its([:header]) { should include("X-Request-Headers" => [include("HTTP_USER_AGENT=#{FunnelHttp::USER_AGENT}")]) }
      end
    end

    context "with lower method" do
      let(:requests) do
        [
          {
            method: "get",
            url: "#{test_server}/get",
            header: {"X-Test-Header" => ["a", "b"]}
          },
        ]
      end

      its(:count) { should eq 1 }

      describe "[0]" do
        subject { responses[0] }

        its([:url]) { should eq "#{test_server}/get" }
        its([:status_code]) { should eq 200 }
        its([:body]) { should eq "/get" }
        its([:header]) { should include("Content-Type" => ["text/plain;charset=utf-8"]) }
        its([:header]) { should include("X-Request-Headers" => [include("HTTP_X_TEST_HEADER=a, b")]) }
        its([:header]) { should include("X-Request-Headers" => [include("HTTP_USER_AGENT=#{FunnelHttp::USER_AGENT}")]) }
      end
    end

    context "with request body" do
      let(:requests) do
        [
          {
            method: "POST",
            url: "#{test_server}/post",
            header: {
              "Content-type" => "application/json",
              "X-Test-Header" => ["a", "b"],
            },
            body: '{"value": "111"}',
          },
          {
            method: "POST",
            url: "#{test_server}/post",
            header: {
              "Content-type" => "application/json",
              "X-Test-Header" => ["c", "d"],
            },
            body: '{"value": "222"}',
          },
        ]
      end

      its(:count) { should eq 2 }

      describe "[0]" do
        subject { responses[0] }

        its([:url]) { should eq "#{test_server}/post" }
        its([:status_code]) { should eq 200 }
        its([:body]) { should eq '{"value": "111"}' }
        its([:header]) { should include("Content-Type" => ["text/plain;charset=utf-8"]) }
        its([:header]) { should include("X-Request-Headers" => [include("HTTP_X_TEST_HEADER=a, b")]) }
        its([:header]) { should include("X-Request-Headers" => [include("HTTP_USER_AGENT=#{FunnelHttp::USER_AGENT}")]) }
      end

      describe "[1]" do
        subject { responses[1] }

        its([:url]) { should eq "#{test_server}/post" }
        its([:status_code]) { should eq 200 }
        its([:body]) { should eq '{"value": "222"}' }
        its([:header]) { should include("Content-Type" => ["text/plain;charset=utf-8"]) }
        its([:header]) { should include("X-Request-Headers" => [include("HTTP_X_TEST_HEADER=c, d")]) }
        its([:header]) { should include("X-Request-Headers" => [include("HTTP_USER_AGENT=#{FunnelHttp::USER_AGENT}")]) }
      end
    end
  end

  describe "#perform!" do
    subject { client.perform!([]) }

    before do
      allow(client).to receive(:perform) { stub_responses }
    end

    context "no errors" do
      let(:stub_responses) do
        [
          {
            url: "http://example.com/200",
            status_code: 200,
            body: "",
            header: {},
          },
          {
            url: "http://example.com/302",
            status_code: 302,
            body: "",
            header: {},
          },
        ]
      end

      it { should eq stub_responses }
    end

    context "contains 1+ errors" do
      let(:stub_responses) do
        [
          {
            url: "http://example.com/200",
            status_code: 200,
            body: "",
            header: {},
          },
          {
            url: "http://example.com/302",
            status_code: 302,
            body: "",
            header: {},
          },
          {
            url: "http://example.com/404",
            status_code: 404,
            body: "",
            header: {},
          },
          {
            url: "http://example.com/502",
            status_code: 502,
            body: "",
            header: {},
          },
        ]
      end

      it { expect { subject }.to raise_error(FunnelHttp::HttpAggregateError, "http://example.com/404 (404 error), http://example.com/502 (502 error)") }

      it "have error_responses" do
        expect { subject }.to raise_error(FunnelHttp::HttpAggregateError) do |error|
          error_responses = [
            {
              url: "http://example.com/404",
              status_code: 404,
              body: "",
              header: {},
            },
            {
              url: "http://example.com/502",
              status_code: 502,
              body: "",
              header: {},
            },
          ]

          expect(error.error_responses).to eq error_responses
        end
      end
    end
  end

  describe "#add_default_request_header" do
    subject do
      client.add_default_request_header(name, value)
      client.default_request_header
    end

    let(:name)  { "X-DEFAULT-CUSTOM" }
    let(:value) { "123" }

    its(["X-DEFAULT-CUSTOM"]) { should eq "123" }
  end

  describe "#normalize_requests" do
    subject { client.normalize_requests(arg) }

    context "arg is Hash" do
      let(:arg) do
        {
          method: "GET",
          url: "http://example.com/get",
          header: {"X-Test-Header" => ["a", "b"]},
        }
      end

      let(:expected) do
        [
          {
            method: "GET",
            url: "http://example.com/get",
            header: {
              "User-Agent" => [FunnelHttp::USER_AGENT],
              "X-Test-Header" => ["a", "b"],
            },
            body: nil,
          }
        ]
      end

      it { should eq expected }
    end

    context "arg is Array of Hash" do
      let(:arg) do
        [
          {
            method: "GET",
            url: "http://example.com/get",
            header: {
              "User-Agent" => [FunnelHttp::USER_AGENT],
              "X-Test-Header" => ["a", "b"],
            },
          }
        ]
      end

      let(:expected) do
        [
          {
            method: "GET",
            url: "http://example.com/get",
            header: {
              "User-Agent" => [FunnelHttp::USER_AGENT],
              "X-Test-Header" => ["a", "b"],
            },
            body: nil,
          }
        ]
      end
    end

    context "header is not Array" do
      let(:arg) do
        {
          method: "GET",
          url: "http://example.com/get",
          header: {"X-Test-Header" => "a"},
        }
      end

      let(:expected) do
        [
          {
            method: "GET",
            url: "http://example.com/get",
            header: {
              "User-Agent" => [FunnelHttp::USER_AGENT],
              "X-Test-Header" => ["a"],
            },
            body: nil,
          }
        ]
      end

      it { should eq expected }
    end

    context "Lack of :header" do
      let(:arg) do
        {
          method: "GET",
          url: "http://example.com/get",
        }
      end

      let(:expected) do
        [
          {
            method: "GET",
            url: "http://example.com/get",
            header: {
              "User-Agent" => [FunnelHttp::USER_AGENT],
            },
            body: nil,
          }
        ]
      end

      it { should eq expected }
    end

    context "with custom header in default_request_header" do
      before do
        client.default_request_header.merge!("X-DEFAULT-CUSTOM" => "123")
      end

      let(:arg) do
        {
          method: "GET",
          url: "http://example.com/get",
          header: {"X-Test-Header" => ["a", "b"]},
        }
      end

      let(:expected) do
        [
          {
            method: "GET",
            url: "http://example.com/get",
            header: {
              "User-Agent" => [FunnelHttp::USER_AGENT],
              "X-Test-Header" => ["a", "b"],
              "X-DEFAULT-CUSTOM" => ["123"],
            },
            body: nil,
          }
        ]
      end

      it { should eq expected }
    end

    context "with non-Hash" do
      let(:arg) { 1 }

      it { expect { subject }.to raise_error(ArgumentError, "1 must be Array or Hash") }
    end

    context "array contains non-Hash" do
      let(:arg) do
        [
          {
            method: "GET",
            url: "http://example.com/get",
            header: {"X-Test-Header" => ["a", "b"]},
          },
          1,
        ]
      end

      it { expect { subject }.to raise_error(ArgumentError, "#{arg} contains something other than Hash") }
    end

    context "Incomplete Hash" do
      let(:arg) do
        {
          method1: "GET",
          url: "http://example.com/get",
          header: {"X-Test-Header" => ["a", "b"]},
        }
      end

      it { expect { subject }.to raise_error(ArgumentError, "#{arg} key does not contain all :method and :url") }
    end
  end
end
