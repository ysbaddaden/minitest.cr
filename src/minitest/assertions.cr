module Minitest
  class Assertion < Exception; end
  class Skip < Exception; end

  module Assertions
    def assert(actual, message = nil)
      return true if actual

      if message
        raise Minitest::Assertion.new(message) if message.is_a?(String)
        raise Minitest::Assertion.new(message.call)
      end

      raise Minitest::Assertion.new("failed assertion")
    end

    def assert(message = nil)
      assert yield, message
    end

    def refute(actual, message = nil)
      assert !actual, message || "failed refutation"
    end

    def refute(message = nil)
      refute yield, message
    end


    def assert_equal(expected, actual, message = nil)
      msg = -> { message || "Expected #{expected.inspect} but got #{actual.inspect}" }
      assert expected == actual, msg
    end

    def refute_equal(expected, actual, message = nil)
      msg = -> { message || "Expected #{expected.inspect} to not be equal to #{actual.inspect}" }
      assert expected != actual, msg
    end


    def assert_match(pattern : Regex, actual, message = nil)
      msg = -> { message || "Expected #{pattern.inspect} to match #{actual.inspect}" }
      assert actual =~ pattern, msg
    end

    def assert_match(pattern, actual, message = nil)
      msg = -> { message || "Expected #{pattern.inspect} to match #{actual.inspect}" }
      assert actual =~ Regex.new(Regex.escape(pattern.to_s)), msg
    end

    def refute_match(pattern : Regex, actual, message = nil)
      msg = -> { message || "Expected #{pattern.inspect} to not match #{actual.inspect}" }
      refute actual =~ pattern, msg
    end

    def refute_match(pattern, actual, message = nil)
      msg = -> { message || "Expected #{pattern.inspect} to not match #{actual.inspect}" }
      refute actual =~ Regex.new(Regex.escape(pattern.to_s)), msg
    end


    def assert_raises(message = nil : String)
      begin
        yield
      rescue ex
        return ex
      end
      raise Assertion.new(message || "Expected an exception but nothing was raised")
    end

    macro assert_raises(klass)
      begin
        {{ yield }}
      rescue __minitest_ex : {{ klass.id }}
        __minitest_ex
      rescue __minitest_ex
        raise Minitest::Assertion.new("Expected #{ {{klass.id}} } but #{__minitest_ex.class} was raised")
      else
        raise Minitest::Assertion.new("Expected #{ {{klass.id}} } but nothing was raised")
      end
    end


    def skip(message = "")
      raise Minitest::Skip.new(message)
    end

    def flunk(message = "Epic Fail!")
      raise Minitest::Assertion.new(message)
    end
  end
end
