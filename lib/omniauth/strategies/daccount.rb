# frozen_string_literal: true
require "omniauth/daccount/version"
require 'omniauth/strategies/oauth2'
require 'uri'

module OmniAuth
  module Strategies
    class Daccount < OmniAuth::Strategies::OAuth2
      # required scope.
      BASE_SCOPES = "openid"
      # 0: Authenticate with contract account only,
      # 1: Authenticate with all account.
      AUTH_IF = 1

      option :name, 'daccount'
      #Include parameters when request-forwarding to authorize.
      option :authorize_options, %i[nounce redirect_uri]
      option :verify_iss, true
      option :callback_path, '/login/docomo_callback'

      # Additional Parameters which requires when authorization requests.
      option :client_options, {
             site: 'https://conf.uw.docomo.ne.jp',
             authorize_url: 'https://id.smt.docomo.ne.jp/cgi8/oidc/authorize',
             token_url: 'https://conf.uw.docomo.ne.jp/common/token',
           }

      def request_phase
        options.client_options[:headers] = {
          "Content-Type" => "application/x-www-form-urlencoded",
          "Host" => full_host
        }
        super
      end

      def authorize_params
        super.tap do |params|
          options[:authorize_options].each do |k|
            params[k] = request.params[k.to_s] unless [nil, ''].include?(request.params[k.to_s])
          end
          params[:scope] = BASE_SCOPES
          params[:authif] = AUTH_IF
          params[:nonce] = params[:state]
          session['omniauth.state'] = params[:state] if params[:state]
        end
      end

      def token_params
        super
      end

      def callback_phase
        super
      end

      uid { raw_info['sub'] }

      info do
        {
          provider: "daccount",
          sub: raw_info['sub'],
          iss: raw_info['iss'],
          name: raw_info['aud'],
        }
      end

      extra do
        {raw_info: raw_info }
      end

      def raw_info
        access_token.options[:mode] = :header
        @raw_info ||= access_token.get('/common/userinfo').parsed
      end

      def callback_url
        full_host + script_name + callback_path
      end

    protected
      def build_access_token
        verifier = request.params["code"]
        params = {redirect_uri: callback_url}.merge(token_params.to_hash)
        base64str = "#{options.client_id}:#{options.client_secret}"
        params[:headers] = {
          "Authorization" => "Basic #{Base64.strict_encode64(base64str)}",
        }
        client.auth_code.get_token(verifier, params, deep_symbolize(options.auth_token_params))
      end

    end
  end
end

OmniAuth.config.add_camelization 'daccount', 'Daccount'
