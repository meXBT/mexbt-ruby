require 'spec_helper'

describe Mexbt::Private do

  context "without authentication" do

    after do
      Mexbt.configure do |c|
         c.public_key = nil
         c.private_key = nil
      end
    end

    it "should raise a friendly error if no keys are configured" do
      expect { Mexbt::Account.balance }.to raise_error("You must configure your API keys!")
    end

    it "should raise a friendly error if no user_id is configured" do
      Mexbt.configure do |c|
        c.public_key = "foo"
        c.private_key = "bar"
      end
      expect { Mexbt::Account.balance }.to raise_error("You must configure your user_id!")
    end

  end

  context "with authentication" do

    before do
      Mexbt.configure do |c|
        c.public_key = "8a742b8ecaff21784d8d788119bded0e"
        c.private_key = "e989fb9c1905a4fbd0a4bfe84230c9bc"
        c.user_id = "test@mexbt.com"
        c.sandbox = true
      end
    end

    after do
      Mexbt.configure do |c|
        c.public_key = nil
        c.user_id = nil
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

end