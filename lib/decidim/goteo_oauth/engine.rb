# frozen_string_literal: true

module Decidim
  module GoteoOauth
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::GoteoOauth

      # Decidim 0.31+ reads OAuth providers from Decidim.omniauth_providers
      # (configured with environment variables) instead of config/secrets.yml.
      initializer "decidim.goteo_oauth.omniauth_provider" do
        Decidim.omniauth_providers[:goteo] ||= {
          enabled: Decidim::Env.new("OMNIAUTH_GOTEO_APP_ID").present?,
          app_id: Decidim::Env.new("OMNIAUTH_GOTEO_APP_ID", nil).value,
          app_secret: Decidim::Env.new("OMNIAUTH_GOTEO_APP_SECRET", nil).value
        }
      end

      # Goteo configuration
      initializer "decidim.goteo_oauth.middleware", after: "decidim.goteo_oauth.omniauth_provider" do |app|
        next unless Decidim.omniauth_providers.dig(:goteo, :enabled)

        app.config.middleware.use OmniAuth::Builder do
          provider(
            :goteo,
            setup: setup_provider_proc(:goteo, client_id: :app_id, client_secret: :app_secret),
            scope: Decidim::GoteoOauth.oauth_scope,
            client_options: Decidim::GoteoOauth.oauth_client_options
          )
        end
      end
    end
  end
end
