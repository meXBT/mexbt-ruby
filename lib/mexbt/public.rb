require 'mexbt/client'
require 'mexbt/common'

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
  end
end