# frozen_string_literal: true

module Decidim
  module GoteoOauth
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::GoteoOauth

      # Goteo configuration
      initializer "decidim.goteo_oauth.middleware" do |app|
        omniauth_config = Rails.application.secrets[:omniauth]

        if omniauth_config[:goteo].present?
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
