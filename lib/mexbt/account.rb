require 'mexbt/common'

module Mexbt
  class Account
    include Mexbt::Common
    include Mexbt::Client

    def initialize(credentials={})
      recognized_credentials = [:public_key, :private_key, :user_id, :currency_pair, :sandbox]
      recognized_credentials.each do |k|
        credential = credentials[k] || Mexbt.send(k)
        instance_variable_set(:"@#{k}", credentials[k])
      end
    end

    def private?
      true
    end

    def sandbox
      @sandbox || Mexbt.sandbox
    end

    def endpoint
      "https://private-api#{sandbox ? '-sandbox' : nil}.mexbt.com"
    end

    %w{info balance orders deposit_addresses}.each do |m|
      define_method(m) do
        call(m == 'info' ? 'me' : m.dasherize)
      end
    end

    %w{btc ltc}.each do |c|
      define_method(:"#{c}_deposit_address") do
        res = call("deposit-addresses")
        res[:addresses].find { |address_info| address_info[:name].downcase === c }[:depositAddress]
      end
    end

    def withdraw(amount:, address:, currency: :btc)
      call("withdraw", { ins: currency, amount: format_amount(amount), sendToAddress: address })
    end

    def create_order(amount:, price: nil, currency_pair: Mexbt.currency_pair, side: :buy, type: :market)
      amount = format_amount(amount)
      type =
        case type
        when :market, 1
          1
        when :limit, 0
          0
        else
          raise "Unknown order type '#{type}'"
        end
      params = {
        ins: currency_pair,
        side: side,
        orderType: type,
        qty: amount
      }
      params[:px] = price if price
      call("orders/create", params)
    end

    def cancel_order(id:, currency_pair: Mexbt.currency_pair)
      call("orders/cancel", { ins: currency_pair, serverOrderId: id })
    end

    def cancel_all_orders(currency_pair: Mexbt.currency_pair)
      call("orders/cancel-all", { ins: currency_pair } )
    end

    def modify_order(id:, action:, currency_pair: Mexbt.currency_pair)
      action =
        case action
        when :move_to_top, 0
          0
        when :execute_now, 1
          1
        else
          raise "Action must be one of: :move_to_top, :execute_now"
        end
      call("orders/modify", { ins: currency_pair, serverOrderId: id, modifyAction: action } )
    end

    private

    def format_amount(amount)
      if sandbox
        # Horribly hack because sandbox only accepts 6 decimal places thanks to AP
        BigDecimal.new(amount, 15).round(6).to_f
      else
        amount
      end
    end
  end
end
