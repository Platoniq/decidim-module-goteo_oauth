# frozen_string_literal: true

require "decidim/goteo_oauth/engine"
require "omniauth/strategies/goteo"

module Decidim
  module GoteoOauth
    include ActiveSupport::Configurable

    config_accessor :oauth_scope do
      :email
    end

    config_accessor :oauth_client_options do
      {
        site: "https://oauth-live.deploy.goteo.org/",
        authorize_url: "https://oauth-live.deploy.goteo.org/:locale/authorize",
        user_info_url: "https://oauth-live.deploy.goteo.org/userInfo",
        token_url: "https://oauth-live.deploy.goteo.org/:locale/token",
        response_type: "authorization_code"
      }
    end
  end
end
