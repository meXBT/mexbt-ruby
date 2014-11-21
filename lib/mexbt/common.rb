module Mexbt
  module Common
    def trades(currency_pair: Mexbt.currency_pair, start_index: -1, count: 10)
      call("trades", { ins: currency_pair, startIndex: start_index, count: count })
    end
  end
end