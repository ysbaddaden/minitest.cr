module Minitest
  class Skip < Exception
  end

  class Assertion < Exception
  end

  module Assertions
    def assert(actual, message = nil)
      raise Minitest::Assertion.new(message || "failed assertion") unless actual
      true
    end

    def assert(message = nil)
      assert(yield, message)
    end

    def refute(actual, message = nil)
      assert(!actual, message || "failed refutation")
    end

    def refute(message = nil)
      refute(yield, message)
    end

    def skip(message = nil)
      raise Minitest::Skip.new(message)
    end

    def flunk(message = "Epic Fail!")
      raise Minitest::Assertion.new(message)
    end
  end
end
