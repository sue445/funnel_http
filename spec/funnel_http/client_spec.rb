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

        its([:status_code]) { should eq 200 }
        its([:body]) { should eq "/get" }
        its([:header]) { should include("Content-Type" => ["text/plain;charset=utf-8"]) }
        its([:header]) { should include("X-Request-Headers" => [include('"HTTP_X_TEST_HEADER"=>"a, b"')]) }
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

        its([:status_code]) { should eq 200 }
        its([:body]) { should eq "/get" }
        its([:header]) { should include("Content-Type" => ["text/plain;charset=utf-8"]) }
        its([:header]) { should include("X-Request-Headers" => [include('"HTTP_X_TEST_HEADER"=>"a, b"')]) }
      end
    end
  end

  describe ".normalize_requests" do
    subject { FunnelHttp::Client.normalize_requests(arg) }

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
            header: {"X-Test-Header" => ["a", "b"]},
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
            header: {"X-Test-Header" => ["a", "b"]},
          }
        ]
      end

      let(:expected) do
        [
          {
            method: "GET",
            url: "http://example.com/get",
            header: {"X-Test-Header" => ["a", "b"]},
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
            header: {"X-Test-Header" => ["a"]},
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
            header: {},
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
