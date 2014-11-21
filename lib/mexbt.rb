require 'active_support/core_ext'
require 'active_support/inflector'
require 'mexbt/public'
require 'mexbt/account'
require 'mexbt/orders'

module Mexbt
  mattr_accessor :public_key
  mattr_accessor :private_key
  mattr_accessor :user_id
  mattr_accessor :currency_pair
  mattr_accessor :sandbox

  @@currency_pair = :btcmxn

  def self.configure
    yield self
  end

  extend Mexbt::Public

  module Account
    extend Mexbt::Account
  end

  module Orders
    extend Mexbt::Orders
  end

end