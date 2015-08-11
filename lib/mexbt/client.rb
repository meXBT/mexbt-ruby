require 'rest_client'

module Mexbt
  module Client
    include RestClient
    SSL_VERSION = :TLSv1_2

    def url(path)
      "#{endpoint()}/v1/#{path}"
    end

    def public_key
      @public_key || Mexbt.public_key
    end

    def private_key
      @private_key || Mexbt.private_key
    end

    def user_id
      @user_id || Mexbt.user_id
    end

    def auth_params
      if public_key.nil? || private_key.nil?
        raise "You must configure your API keys!"
      end
      if user_id.nil?
        raise "You must configure your user_id!"
      end
      nonce = (Time.now.to_f*10000).to_i
      {
        apiKey: public_key,
        apiNonce: nonce,
        apiSig: OpenSSL::HMAC.hexdigest('sha256', private_key, "#{nonce}#{user_id}#{public_key}").upcase
      }
    end

    def call(path, params={})
      payload = params
      params.merge!(auth_params) if self.respond_to?(:private?)
      res = Request.execute(method: :post, url: url(path), payload: payload.to_json, ssl_version: SSL_VERSION)
      if res.length === 0
        raise "Empty response from API"
      end
      json_response = ActiveSupport::HashWithIndifferentAccess.new(JSON.parse(res))
      if json_response[:isAccepted]
        json_response
      else
        raise json_response[:rejectReason]
      end
    end

    def call_data(path)
      res = Request.execute(method: :get, url: "https://data.mexbt.com/#{path}", ssl_version: SSL_VERSION)
      ActiveSupport::HashWithIndifferentAccess.new(JSON.parse(res))
    end
  end
end
