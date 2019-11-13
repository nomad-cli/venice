module Venice
  class Environment < Struct.new(:name, :endpoint)
    PRODUCTION = new('production', 'https://buy.itunes.apple.com/verifyReceipt')
    DEVELOPMENT = new('development', 'https://sandbox.itunes.apple.com/verifyReceipt')
  end
end
