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

      option :client_options, {#authorizationリクエスト時の追加パラメータ
             site: 'https://conf.uw.docomo.ne.jp',
             authorize_url: 'https://id.smt.docomo.ne.jp/cgi8/oidc/authorize',
             token_url: 'https://conf.uw.docomo.ne.jp/token/o/oauth2/auth',
             headers: {
               'Content-Type' => 'application/x-www-form-urlencoded',
               'Host' => full_host
             }
           }

      def request_phase
        p "#{client.options}"
        redirect client.auth_code.authorize_url({:redirect_uri => callback_url}.merge(authorize_params))
      end

      def authorize_params
        super.tap do |params|
          options[:authorize_options].each do |k|
            params[k] = request.params[k.to_s] unless [nil, ''].include?(request.params[k.to_s])
          end
          params[:scope] = BASE_SCOPES
          session['omniauth.state'] = params[:state] if params[:state]
        end
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
        access_token.options[:headers] = {
          'Authorization' =>  BASE_HOST,
          'Content-Type' => 'application/x-www-form-urlencoded',
          'Host' => full_host,
        }
        @raw_info ||= access_token.get('userinfo').parsed
      end

    end
  end
end

OmniAuth.config.add_camelization 'daccount', 'Daccount'
