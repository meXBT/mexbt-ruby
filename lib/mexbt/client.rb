require 'rest_client'

module Mexbt
  module Client
    include RestClient
    SSL_VERSION = :TLSv1_2

    def url(path)
      "#{endpoint()}/v1/#{path}"
    end

    def auth_params
      if Mexbt.public_key.nil? || Mexbt.private_key.nil?
        raise "You must configure your API keys!"
      end
      nonce = (Time.now.to_f*10000).to_i
      {
        apiKey: Mexbt.public_key,
        apiNonce: nonce,
        apiSig: OpenSSL::HMAC.hexdigest('sha256', Mexbt.private_key, "#{nonce}#{Mexbt.user_id}#{Mexbt.public_key}").upcase
      }
    end

    def call(path, params={})
      payload = params
      params.merge!(auth_params) if self.respond_to?(:private?)
      res = Request.execute(method: :post, url: url(path), payload: payload.to_json, ssl_version: SSL_VERSION)
      if res.length === 0
        raise "Empty response from API"
      end
      json_response = JSON.parse(res)
      if json_response["isAccepted"]
        json_response
      else
        raise json_response["rejectReason"]
      end
    end
  end
end