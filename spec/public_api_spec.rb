require 'spec_helper'

describe Mexbt do

  it "gives a valid response to all public api functions that require no args" do
    %w{ticker trades currency_pairs product_pairs orders order_book}.each do |f|
      res = Mexbt.send(f)
      expect(res["isAccepted"]).to be true
    end
  end

  it "allows passing a custom currency pair to functions that accept it" do
    %w{ticker trades orders order_book}.each do |f|
      res = Mexbt.send(f, currency_pair: 'BTCUSD')
      expect(res["isAccepted"]).to be true
    end
  end

  it "allows you to fetch trades by date range" do
    res = Mexbt.trades_by_date(from: Time.now.to_i, to: Time.now.to_i)
    expect(res["isAccepted"]).to be true
    expect(res["trades"]).to eql([])
  end

end