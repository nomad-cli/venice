module Venice
  VERSION = "0.0.1"

  def self.shared_secret
    @@shared_secret
  end

  def self.shared_secret=(secret)
    @@shared_secret = secret
  end
  self.shared_secret = nil
end

require 'venice/client'
require 'venice/receipt'
