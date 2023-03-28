# frozen_string_literal: true

module OmniAuth
  module Strategies
    class Goteo < OmniAuth::Strategies::OAuth2
      option :name, "goteo"
      option :client_options, {
        site: "https://oauth-live.deploy.goteo.org/",
        authorize_url: "https://oauth-live.deploy.goteo.org/authorize",
        user_info_url: "https://oauth-live.deploy.goteo.org/userInfo",
        token_url: "https://oauth-live.deploy.goteo.org/token",
        response_type: "authorization_code"
      }

      option :token_params, {}
      option :auth_token_params, {}
      option :token_options, [:client_id]
      option :pkce, true

      uid do
        raw_info["username"]
      end

      info do
        {
          email: raw_info["email"],
          email_verified: raw_info["email_verified"],
          locale: raw_info["locale"],
          name: raw_info["name"],
          picture: raw_info["picture"],
          sub: raw_info["sub"],
          nickname: raw_info["username"],
          username: raw_info["username"]
        }
      end

      extra do
        {}
      end

      def raw_info
        @raw_info ||= access_token.get(options.client_options[:user_info_url], {}).parsed || {}
        @raw_info
      end

      def build_access_token
        ::OAuth2::Client.new(options.client_id, options.client_secret, opts).auth_code
                        .get_token(verifier,
                                   { redirect_uri: (full_host + callback_path) }.merge(token_params.to_hash(symbolize_keys: true)),
                                   deep_symbolize(options.auth_token_params))
      end

      def client
        locale = request.params["locale"] || I18n.locale
        options.client_options["authorize_url"] = options.client_options["authorize_url"].gsub("/:locale", "/#{locale}")
        ::OAuth2::Client.new(options.client_id, options.client_secret, deep_symbolize(options.client_options))
      end

      def callback_url
        full_host + callback_path
      end

      def verifier
        request.params["code"]
      end

      def opts
        local_opts = deep_symbolize(options.client_options)
        local_opts[:token_url] = "#{local_opts[:token_url]}?client_id=#{options.client_id}&response_type=code"
        local_opts
      end
    end
  end
end
