require 'mexbt/private'
require 'mexbt/common'

module Mexbt
  module Account
    include Mexbt::Private
    include Mexbt::Common

    %w{info balance orders deposit_addresses}.each do |m|
      define_method(m) do
        call(m == 'info' ? 'me' : m.dasherize)
      end
    end

    def withdraw(amount:, address:, currency: :btc)
      call("withdraw", { ins: currency, amount: amount, sentToAddress: address })
    end
  end
end