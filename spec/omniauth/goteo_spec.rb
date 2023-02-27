# frozen_string_literal: true

require "spec_helper"

describe OmniAuth::Strategies::Goteo do
  before do
    WebMock.disable_net_connect!
  end

  let(:app) do
    Rack::Builder.new do
      use OmniAuth::Test::PhonySession
      use OmniAuth::Strategies::Goteo, "id123", "secretabc"
      run ->(env) { [404, { "Content-Type" => "text/plain" }, [env.key?("omniauth.auth").to_s]] }
    end.to_app
  end

  it "responds to the default auth URL (oauth2_generic)" do
    get "/auth/goteo"
    expect(last_response).to be_redirect
  end
end
