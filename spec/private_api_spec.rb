require 'spec_helper'

describe Mexbt::Private do

  before do
    Mexbt.configure do | mexbt |
      mexbt.public_key = "1d039abd0e667a4e03767ddef11cb8d5"
      mexbt.private_key = "0e5a8d04838fc43f0f4335c8a380f200"
      mexbt.user_id = "test@mexbt.com"
      mexbt.sandbox = true
    end
  end

  context Mexbt::Account do

    it "gives a valid response to all public api functions that require no args" do
      %w{info balance orders deposit_addresses trades}.each do |f|
        res = Mexbt::Account.send(f)
        expect(res["isAccepted"]).to be true
      end
    end

  end

  context Mexbt::Orders do

    it "allows creating market orders" do
      res = Mexbt::Orders.create(amount: 0.1, currency_pair: "BTCUSD")
      expect(res["isAccepted"]).to be true
      expect(res["serverOrderId"]).to be_a(Fixnum)
    end

    it "allows creating limit orders" do
      res = Mexbt::Orders.create(type: :limit, price: 100, amount: 0.1234, currency_pair: "BTCUSD")
      expect(res["isAccepted"]).to be true
      expect(res["serverOrderId"]).to be_a(Fixnum)
    end

    it "raises an exception if order type not recognised" do
      expect { Mexbt::Orders.create(type: :boom, amount: 0.2) }.to raise_error("Unknown order type 'boom'")
    end

    context "modifying and cancelling orders" do

      let(:order_id) {Mexbt::Orders.create(type: :limit, price: 100, amount: 0.1, currency_pair: "BTCUSD")["serverOrderId"]}

      it "allows converting limit orders to market orders" do
        res = Mexbt::Orders.modify(id: order_id, currency_pair: "BTCUSD", action: :execute_now)
        expect(res["isAccepted"]).to be true
      end

      it "allows moving orders to the top of the book" do
        res = Mexbt::Orders.modify(id: order_id, currency_pair: "BTCUSD", action: :move_to_top)
        expect(res["isAccepted"]).to be true
      end

      it "allows cancelling individual orders" do
        res = Mexbt::Orders.cancel(id: order_id, currency_pair: "BTCUSD")
        expect(res["isAccepted"]).to be true
        orders = Mexbt::Account.orders["openOrdersInfo"]
        orders.each do |open_orders|
          if open_orders["ins"] === "BTCUSD"
            open_orders["openOrders"].each do |usd_order|
              if usd_order["ServerOrderId"] === order_id
                fail("Order was cancelled but still open")
              end
            end
          end
        end
      end

      it "allows cancelling all orders" do
        res = Mexbt::Orders.cancel_all(currency_pair: "BTCUSD")
        expect(res["isAccepted"]).to be true
        orders = Mexbt::Account.orders["openOrdersInfo"]
        orders.each do |open_orders|
          if open_orders["ins"] === "BTCUSD"
            expect(open_orders["openOrders"]).to eql([])
          end
        end
      end
    end

  end

end