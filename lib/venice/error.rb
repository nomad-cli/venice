module Venice
  class Error < StandardError
    attr_accessor :code

    def initialize(data)
      @code = data[:code]
      super(data[:message])
    end
  end
end
