# frozen_string_literal: true

module Decidim
  module GoteoOauth
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::GoteoOauth

      # Goteo configuration
      initializer "decidim.goteo_oauth.middleware" do |app|
        secrets_path = Rails.root.join("config/secrets.yml")
        omniauth_config = secrets_path.exist? ? Rails.application.config_for(:secrets)[:omniauth] : nil

        if omniauth_config&.dig(:goteo).present?
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
end
