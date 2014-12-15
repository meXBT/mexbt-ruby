require 'mexbt/client'
require 'mexbt/common'
require 'active_support'

module Mexbt
  module Public
    include Mexbt::Client
    include Mexbt::Common

    def endpoint
      "https://public-api.mexbt.com"
    end

    def ticker(currency_pair: Mexbt.currency_pair)
      call("ticker", { productPair: currency_pair })
    end

    def order_book(currency_pair: Mexbt.currency_pair)
      call("order-book", { productPair: currency_pair })
    end

    alias :orders :order_book

    def currency_pairs
      call("product-pairs")
    end

    alias :product_pairs :currency_pairs

    def trades_by_date(currency_pair: Mexbt.currency_pair, from:, to:)
      call("trades-by-date", { ins: currency_pair, startDate: from, endDate: to })
    end

    def simulate_market_order(side: :buy, first_currency: 0, second_currency: 0, currency_pair: Mexbt.currency_pair)
      if first_currency === 0 and second_currency === 0
        raise "You must specify either 'first_currency' or 'second_currency' (from the currency pair)"
      end
      order_book = order_book(currency_pair: currency_pair)
      orders =
        if side.to_s === 'buy'
          order_book["asks"].sort { |a, b| a["px"] <=> b["px"] }
        else
          order_book["bids"].sort { |a, b| b["px"] <=> a["px"] }
        end
      if second_currency > 0
        threshold_target = second_currency
        threshold_symbol = :cost
        other_symbol = :amount
      else
        threshold_target = first_currency
        threshold_symbol = :amount
        other_symbol = :cost
      end
      sums = {
        amount: BigDecimal.new(0, 15),
        cost: BigDecimal.new(0, 15)
      }
      orders.each do |order|
        next_order = {
          amount: BigDecimal.new(order["qty"], 15),
          cost: BigDecimal.new(order["px"], 15) * BigDecimal.new(order["qty"], 15)
        }
        threshold_check = sums[threshold_symbol] + next_order[threshold_symbol]
        if threshold_check > threshold_target
          over = threshold_check - threshold_target
          percent_needed = (next_order[threshold_symbol] - over) / next_order[threshold_symbol]
          sums[other_symbol] += next_order[other_symbol] * percent_needed
          sums[threshold_symbol] = threshold_target
          break
        else
          sums[:amount] += next_order[:amount]
          sums[:cost] += next_order[:cost]
          break if sums[threshold_symbol] == threshold_target
        end
      end
      if sums[threshold_symbol] < threshold_target
        raise "Order book does not contain enough orders to satify simulated order!"
      end
      res = {
        first_amount: round(sums[:amount], currency_pair, :first),
        second_amount: round(sums[:cost], currency_pair, :second)
      }
      ActiveSupport::HashWithIndifferentAccess.new(res)
    end

    private

    def round(amount, pair, which)
      currency = which === :first ? pair.to_s[0,3] : pair.to_s[-3..-1]
      decimal_places =
        if ['btc', 'ltc'].include?(currency.downcase)
          8
        else
          2
        end
      amount.round(decimal_places).to_f
    end
  end
end