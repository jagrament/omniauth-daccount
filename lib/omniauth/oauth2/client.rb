require "oauth2"

module OmniAuth
  module OAuth2
    class Client < OAuth2::Client
      def get_token(params, access_token_opts = {}, access_token_class = AccessToken) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        params = Authenticator.new(id, secret, options[:auth_scheme]).apply(params)
        opts = {:raise_errors => options[:raise_errors], :parse => params.delete(:parse)}
        headers = params.delete(:headers) || {}
        if options[:token_method] == :post
          opts[:body] = params
          opts[:headers] = {
            'Content-Type' => 'application/x-www-form-urlencoded',
            'Content-Length' => params.to_s.length
          }
        else
          opts[:params] = params
          opts[:headers] = {}
        end
        opts[:headers].merge!(headers)
        response = request(options[:token_method], token_url, opts)
        if options[:raise_errors] && !(response.parsed.is_a?(Hash) && response.parsed['access_token'])
          error = Error.new(response)
          raise(error)
        end
        access_token_class.from_hash(self, response.parsed.merge(access_token_opts))
      end
    end
  end
end
