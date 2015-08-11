require 'spec_helper'

describe Mexbt::Account do

  context "without authentication" do

    subject(:account) { Mexbt::Account.new }

    after do
      Mexbt.configure do |c|
         c.public_key = nil
         c.private_key = nil
      end
    end

    it "should raise a friendly error if no keys are configured" do
      expect { account.balance }.to raise_error("You must configure your API keys!")
    end

    it "should raise a friendly error if no user_id is configured" do
      Mexbt.configure do |c|
        c.public_key = "foo"
        c.private_key = "bar"
      end
      expect { account.balance }.to raise_error("You must configure your user_id!")
    end

  end

  context "with per-instance authentication" do

    subject(:account) { Mexbt::Account.new(public_key: "b202ba1efcfd3dd1ceef0e7961d21c05", private_key: "0dca4a65faf9005c5743df92309747b2", user_id: "specs@mexbt.com", sandbox: true) }

    it "still works" do
      expect(account.info[:isAccepted]).to be true
    end

  end

  context "with authentication" do

    subject(:account) { Mexbt::Account.new }

    before do
      Mexbt.configure do |c|
        c.public_key = "b202ba1efcfd3dd1ceef0e7961d21c05"
        c.private_key = "0dca4a65faf9005c5743df92309747b2"
        c.user_id = "specs@mexbt.com"
        c.sandbox = true
      end
    end

    after do
      Mexbt.configure do |c|
        c.public_key = nil
        c.user_id = nil
      end
    end

    it "gives a valid response to all api functions that require no args" do
      %w{info balance orders deposit_addresses trades}.each do |f|
        res = account.send(f)
        expect(res[:isAccepted]).to be true
      end
    end

    it "allows creating market orders" do
      res = account.create_order(amount: 0.1, currency_pair: "BTCUSD")
      expect(res[:isAccepted]).to be true
      expect(res[:serverOrderId]).to be_a(Fixnum)
    end

    it "allows creating orders with 8 decimal places" do
      res = account.create_order(amount: 0.12345678, currency_pair: "BTCUSD")
      expect(res[:isAccepted]).to be true
      expect(res[:serverOrderId]).to be_a(Fixnum)
    end

    it "rounds orders with more than 8 decimal places" do
      res = account.create_order(amount: 0.12345678910, currency_pair: "BTCUSD")
      expect(res[:isAccepted]).to be true
      expect(res[:serverOrderId]).to be_a(Fixnum)
    end

    it "allows creating limit orders" do
      res = account.create_order(type: :limit, price: 100, amount: 0.1234, currency_pair: "BTCUSD")
      expect(res[:isAccepted]).to be true
      expect(res[:serverOrderId]).to be_a(Fixnum)
    end

    it "raises an exception if order type not recognised" do
      expect { account.create_order(type: :boom, amount: 0.2) }.to raise_error("Unknown order type 'boom'")
    end

    it "returns the btc deposit address" do
      expect(account.btc_deposit_address).to eql("SIM MODE - No addresses in Sim Mode")
    end

    it "returns the ltc deposit address" do
      expect(account.ltc_deposit_address).to eql("SIM MODE - No addresses in Sim Mode")
    end

    context "modifying and cancelling orders" do

      let(:order_id) {account.create_order(type: :limit, price: 100, amount: 0.1, currency_pair: "BTCUSD")[:serverOrderId]}

      it "allows converting limit orders to market orders" do
        res = account.modify_order(id: order_id, currency_pair: "BTCUSD", action: :execute_now)
        expect(res[:isAccepted]).to be true
      end

      it "allows moving orders to the top of the book" do
        res = account.modify_order(id: order_id, currency_pair: "BTCUSD", action: :move_to_top)
        expect(res[:isAccepted]).to be true
      end

      it "allows cancelling individual orders" do
        res = account.cancel_order(id: order_id, currency_pair: "BTCUSD")
        expect(res[:isAccepted]).to be true
        orders = account.orders[:openOrdersInfo]
        orders.each do |open_orders|
          if open_orders[:ins] === "BTCUSD"
            open_orders[:openOrders].each do |usd_order|
              if usd_order[:ServerOrderId] === order_id
                fail("Order was cancelled but still open")
              end
            end
          end
        end
      end

      it "allows cancelling all orders" do
        res = account.cancel_all_orders(currency_pair: "BTCUSD")
        expect(res[:isAccepted]).to be true
        orders = account.orders[:openOrdersInfo]
        orders.each do |open_orders|
          if open_orders[:ins] === "BTCUSD"
            expect(open_orders[:openOrders]).to eql([])
          end
        end
      end
    end

  end

end
