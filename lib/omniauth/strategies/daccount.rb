# frozen_string_literal: true
require "omniauth/daccount/version"
require 'multi_json'
require 'omniauth/strategies/oauth2'
require 'uri'

module OmniAuth
  module Strategies
    class Daccount < OmniAuth::Strategies::OAuth2
      BASE_SCOPES = "openid"
      option :name, 'daccount'
      #authorizeにリクエストフォワードする時のapp側のパラメータ値にこれらを含めること。
      option :authorize_options, %i[nounce redirect_uri]
      option :verify_iss, true
      option :callback_path, '/login/docomo_callback'

      option :client_options, {#authorizationリクエスト時の追加パラメータ
             site: 'https://conf.uw.docomo.ne.jp',
             authorize_url: 'https://id.smt.docomo.ne.jp/cgi8/oidc/authorize',
             token_url: 'https://conf.uw.docomo.ne.jp/token',
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
        prune!(
          provider: "daccount",
          sub: raw_info['sub'],
          iss: raw_info['iss'],
          name: raw_info['name'],
          picture: raw_info['picture'],
        )
      end

      extra do
        {raw_info: raw_info }
      end

      def raw_info
        access_token.options[:mode] = :query
        access_token.options[:headers].merge({
          'Content-Type' => 'application/x-www-form-urlencoded',
          'Host' => full_host,
        })
        p access_token
        @raw_info ||= access_token.get('userinfo',).parsed
        p @raw_info
      end

    protected

      def build_access_token
        verifier = request.params["code"]
        params = {:redirect_uri => callback_url}.merge(token_params.to_hash)
        base64str = "#{options.client_id}:#{options.client_secret}"
        params[:headers] = {
          "Host" => full_host,
          "Authorization" => "Basic #{Base64.encode64(base64str)}",
        }

        client.auth_code.get_token(verifier, params, deep_symbolize(options.auth_token_params))
      end

    end
  end
end

OmniAuth.config.add_camelization 'daccount', 'Daccount'
