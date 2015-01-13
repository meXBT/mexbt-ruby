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

  it "fetches btcmxn order book data from data API if AP API down" do
    expect(Mexbt).to receive(:call).with("order-book", { productPair: :btcmxn }).and_raise("Boom")
    order_book = Mexbt.order_book
    expect(order_book["asks"].first["px"]).to be_a_kind_of(Numeric)
    expect(order_book["asks"].first["qty"]).to be_a_kind_of(Numeric)
    expect(order_book["bids"].first["px"]).to be_a_kind_of(Numeric)
    expect(order_book["bids"].first["qty"]).to be_a_kind_of(Numeric)
  end

  it "simulates market order using data api data if AP API down" do
    expect(Mexbt).to receive(:call).with("order-book", { productPair: :btcmxn }).and_raise("Boom")
    expect(Mexbt.simulate_market_order(second_currency: 100)["first_amount"]).to be_a_kind_of(Numeric)
  end

  context "simulating market orders" do

    before do
      allow(Mexbt).to receive(:order_book) do
        {
          "asks" => [{"px" => 1000, "qty" => 0.5}, {"px" => 2000, "qty" => 1}],
          "bids" => [{"px" => 1000, "qty" => 0.5}, {"px" => 2000, "qty" => 1}]
        }
      end
    end

    it "calculates correctly buy orders with second_currency as the target currency" do
      expect(Mexbt.simulate_market_order(second_currency: 100)["first_amount"]).to eql(0.1)
      expect(Mexbt.simulate_market_order(second_currency: 500)["first_amount"]).to eql(0.5)
      expect(Mexbt.simulate_market_order(second_currency: 600)["first_amount"]).to eql(0.55)
      expect(Mexbt.simulate_market_order(second_currency: 1500)["first_amount"]).to eql(1.0)
      expect(Mexbt.simulate_market_order(second_currency: 2500)["first_amount"]).to eql(1.5)
      expect { Mexbt.simulate_market_order(second_currency: 2501)}.to raise_error("Order book does not contain enough orders to satify simulated order!")
    end

    it "calculates correctly buy orders with first_currency as the target currency" do
      expect(Mexbt.simulate_market_order(first_currency: 0.5)["second_amount"]).to eql(500.0)
      expect(Mexbt.simulate_market_order(first_currency: 1.5)["second_amount"]).to eql(2500.0)
      expect(Mexbt.simulate_market_order(first_currency: 0.1)["second_amount"]).to eql(100.0)
      expect(Mexbt.simulate_market_order(first_currency: 0.6)["second_amount"]).to eql(700.0)
    end

    it "calculates correctly sell orders with first_currency as the target currency" do
      expect(Mexbt.simulate_market_order(side: :sell, first_currency: 0.01)["second_amount"]).to eql(20.0)
      expect(Mexbt.simulate_market_order(side: :sell, first_currency: 0.1)["second_amount"]).to eql(200.0)
      expect(Mexbt.simulate_market_order(side: :sell, first_currency: 1)["second_amount"]).to eql(2000.0)
      expect(Mexbt.simulate_market_order(side: :sell, first_currency: 1.1)["second_amount"]).to eql(2100.0)
      expect(Mexbt.simulate_market_order(side: :sell, first_currency: 1.4)["second_amount"]).to eql(2400.0)
    end

    it "calculates correctly sell orders with second_currency as the target currency" do
      expect(Mexbt.simulate_market_order(side: :sell, second_currency: 1000)["first_amount"]).to eql(0.5)
      expect(Mexbt.simulate_market_order(side: :sell, second_currency: 2001)["first_amount"]).to eql(1.001)
      expect(Mexbt.simulate_market_order(side: :sell, second_currency: 2500)["first_amount"]).to eql(1.5)
    end
  end

end