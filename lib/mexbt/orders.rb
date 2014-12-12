require 'mexbt/private'

module Mexbt
  module Orders
    include Mexbt::Private

    def create(amount:, price: nil, currency_pair: Mexbt.currency_pair, side: :buy, type: :market)
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

    def cancel(id:, currency_pair: Mexbt.currency_pair)
      call("orders/cancel", { ins: currency_pair, serverOrderId: id })
    end

    def cancel_all(currency_pair: Mexbt.currency_pair)
      call("orders/cancel-all", { ins: currency_pair } )
    end

    def modify(id:, action:, currency_pair: Mexbt.currency_pair)
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

  end
end
