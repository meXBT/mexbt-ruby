require 'mexbt/client'


module Mexbt
  module Private
    include Mexbt::Client

    def private?
      true
    end

    def endpoint
      "https://private-api#{Mexbt.sandbox ? '-sandbox' : nil}.mexbt.com"
    end
  end
end