# frozen_string_literal: true

require "spec_helper"

describe OmniAuth::Strategies::Goteo do
  subject do
    described_class.new({}, "appid", "secret", **options).tap do |strategy|
      allow(strategy).to receive_messages(request:, session: [])
    end
  end

  before do
    stub_request(:post, "https://oauth-live.deploy.goteo.org/:locale/token?client_id=appid&response_type=code")
      .with(
        body: { "client_id" => "appid", "code" => nil, "code_verifier" => nil, "foo" => "bar",
                "grant_type" => "authorization_code", "redirect_uri" => "/users/auth/goteo/callback" },
        headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization" => "Basic YXBwaWQ6c2VjcmV0",
          "Content-Type" => "application/x-www-form-urlencoded",
          "User-Agent" => "Faraday v2.7.4"
        }
      )
      .to_return(status: 200, body: "", headers: {})
  end

  let(:request) { double("Request", params: {}, cookies: {}, env: {}, scheme: "https", url: "") }

  let(:options) { {} }
  let(:raw_info_hash) do
    {
      username: "foo",
      nickname: "foo",
      email_verified: true,
      locale: "ca",
      name: "Foo Bar",
      email: "foo@example.com"
    }
  end

  describe "client options" do
    it "has correct name" do
      expect(subject.options.name).to eq("goteo")
    end

    it "has correct site" do
      expect(subject.options.client_options.site).to eq("https://oauth-live.deploy.goteo.org/")
    end

    it "has correct authorize url" do
      expect(subject.options.client_options.authorize_url).to eq("https://oauth-live.deploy.goteo.org/:locale/authorize")
    end

    it "has correct user info url" do
      expect(subject.options.client_options.user_info_url).to eq("https://oauth-live.deploy.goteo.org/userInfo")
    end

    it "has correct token url" do
      expect(subject.options.client_options.token_url).to eq("https://oauth-live.deploy.goteo.org/:locale/token")
    end

    it "has correct authorization_code" do
      expect(subject.options.client_options.response_type).to eq("authorization_code")
    end
  end

  describe "info" do
    before do
      # rubocop: disable RSpec/SubjectStub
      allow(subject).to receive(:raw_info).and_return(raw_info_hash)
      # rubocop: enable RSpec/SubjectStub
    end

    it "returns the uid" do
      expect(subject.uid).to eq(raw_info_hash["username"])
    end

    it "returns the extra" do
      expect(subject.extra).to eq({})
    end

    it "returns the username" do
      expect(subject.info[:username]).to eq(raw_info_hash["username"])
    end

    it "returns the nickname" do
      expect(subject.info[:nickname]).to eq(raw_info_hash["username"])
    end

    it "returns the email_verified" do
      expect(subject.info[:email_verified]).to eq(raw_info_hash["email_verified"])
    end

    it "returns the locale" do
      expect(subject.info[:locale]).to eq(raw_info_hash["locale"])
    end

    it "returns the name" do
      expect(subject.info[:name]).to eq(raw_info_hash["name"])
    end

    it "returns the email" do
      expect(subject.info[:email]).to eq(raw_info_hash["email"])
    end
  end

  describe "opts" do
    [:site, :authorize_url, :user_info_url, :response_type].each do |option|
      it { expect(subject.opts[option]).to eq(subject.options.client_options.send(option)) }
    end

    it { expect(subject.opts[:token_url]).to eq("https://oauth-live.deploy.goteo.org/:locale/token?client_id=appid&response_type=code") }
  end

  describe "verifier" do
    let(:request) { double("Request", params: { "code" => "foo bar" }, cookies: {}, env: {}, scheme: "https") }

    it { expect(subject.verifier).to eq("foo bar") }
  end

  describe "build_access_token" do
    let(:gt_params) { [nil, { client_id: "appid", code_verifier: nil, redirect_uri: "/users/auth/goteo/callback" }, {}] }

    # rubocop: disable RSpec/NoExpectationExample
    it "creates the access token" do
      auth_code = instance_double(OAuth2::Strategy::AuthCode)
      access_token = instance_double(OAuth2::AccessToken)
      allow(auth_code).to receive(:get_token).with(*gt_params).and_return(access_token)
      # rubocop: disable RSpec/AnyInstance
      allow_any_instance_of(OAuth2::Client).to receive(:auth_code).and_return(auth_code)
      # rubocop: enable RSpec/AnyInstance

      subject.build_access_token
    end
    # rubocop: enable RSpec/NoExpectationExample
  end

  describe "raw_info" do
    it "returns the hash" do
      response = instance_double(OAuth2::Response)
      allow(response).to receive(:parsed).and_return(raw_info_hash)
      access_token = instance_double(OAuth2::AccessToken)
      allow(access_token).to receive(:get).and_return(response)

      subject.access_token = access_token
      expect(subject.raw_info).to eq(raw_info_hash)
    end
  end
end
