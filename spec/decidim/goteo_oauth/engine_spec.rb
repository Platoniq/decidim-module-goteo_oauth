# frozen_string_literal: true

require "spec_helper"

describe Decidim::GoteoOauth::Engine do
  it "registers the Goteo provider from the environment" do
    expect(Decidim.omniauth_providers[:goteo]).to include(:enabled, :app_id, :app_secret)
  end

  it "is disabled without OMNIAUTH_GOTEO_APP_ID" do
    expect(Decidim.omniauth_providers[:goteo][:enabled]).to be(false)
  end
end
