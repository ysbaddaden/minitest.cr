class Exception
  getter :file, :line

  # NOTE: hack to report the source location that raised
  def initialize(@message = nil : String?, @cause = nil : Exception?, @file = __FILE__, @line = __LINE__)
    @backtrace = caller
    @callstack = CallStack.new
  end

  def location
    "#{file}:#{line}"
  end
end

module Minitest
  module LocationFilter
    def file
      file = @file.to_s
      dir = Dir
      cwd = if dir.responds_to?(:current)
              dir.current           # crystal > 0.9.1
            elsif dir.responds_to?(:working_directory)
              dir.working_directory # crystal <= 0.9.1
            else
              raise "unreachable"
            end
      file.starts_with?(cwd) ? file[(cwd.size + 1) .. -1] : file
    end
  end

  # Decorator for the original exception.
  class UnexpectedError < Exception
    include LocationFilter

    getter :exception

    def initialize(@exception)
      super "#{exception.class.name}: #{exception.message}"
      @file = exception.file
    end

    def backtrace
      if pos = exception.backtrace.index { |f| f.index("@Minitest::Test#run_tests") }
        exception.backtrace[0 ... pos]
      else
        exception.backtrace
      end
    end

    def location
      "#{file}:#{exception.line}"
    end
  end

  class Assertion < Exception
    include LocationFilter
  end

  class Skip < Exception
    include LocationFilter
  end

  # TODO: assert_output / refute_output
  # TODO: assert_silent / refute_silent
  module Assertions
    def assert(actual, message = nil, file = __FILE__, line = __LINE__)
      return true if actual

      if message
        raise Minitest::Assertion.new(message, file: file, line: line) if message.is_a?(String)
        raise Minitest::Assertion.new(message.call, file: file, line: line)
      end

      raise Minitest::Assertion.new("failed assertion", file: file, line: line)
    end

    def assert(message = nil, file = __FILE__, line = __LINE__)
      assert yield, message, file, line
    end

    def refute(actual, message = nil, file = __FILE__, line = __LINE__)
      assert !actual, message || "failed refutation", file, line
    end

    def refute(message = nil, file = __FILE__, line = __LINE__)
      refute yield, message, file, line
    end


    def assert_equal(expected, actual, message = nil, file = __FILE__, line = __LINE__)
      msg = -> { message || "Expected #{expected.inspect} but got #{actual.inspect}" }
      assert expected == actual, msg, file, line
    end

    def refute_equal(expected, actual, message = nil, file = __FILE__, line = __LINE__)
      msg = -> { message || "Expected #{expected.inspect} to not be equal to #{actual.inspect}" }
      assert expected != actual, msg, file, line
    end


    def assert_same(expected, actual, message = nil, file = __FILE__, line = __LINE__)
      msg = -> {
        message || "Expected #{actual.inspect} (oid=#{actual.object_id}) " +
        "to be the same as #{expected.inspect} (oid=#{expected.object_id})"
      }
      if expected.responds_to?(:same?)
        assert expected.same?(actual), msg, file, line
      else
        assert_responds_to expected, :same?, nil, file, line
      end
    end

    def refute_same(expected, actual, message = nil, file = __FILE__, line = __LINE__)
      msg = -> {
        message || "Expected #{actual.inspect} (oid=#{actual.object_id}) " +
        "to not be the same as #{expected.inspect} (oid=#{expected.object_id})"
      }
      if expected.responds_to?(:same?)
        refute expected.same?(actual), msg, file, line
      else
        assert_responds_to expected, :same?, nil, file, line
      end
    end


    def assert_match(pattern : Regex, actual, message = nil, file = __FILE__, line = __LINE__)
      msg = -> { message || "Expected #{pattern.inspect} to match #{actual.inspect}" }
      assert actual =~ pattern, msg, file, line
    end

    def assert_match(pattern, actual, message = nil, file = __FILE__, line = __LINE__)
      msg = -> { message || "Expected #{pattern.inspect} to match #{actual.inspect}" }
      assert actual =~ Regex.new(Regex.escape(pattern.to_s)), msg, file, line
    end

    def refute_match(pattern : Regex, actual, message = nil, file = __FILE__, line = __LINE__)
      msg = -> { message || "Expected #{pattern.inspect} to not match #{actual.inspect}" }
      refute actual =~ pattern, msg, file, line
    end

    def refute_match(pattern, actual, message = nil, file = __FILE__, line = __LINE__)
      msg = -> { message || "Expected #{pattern.inspect} to not match #{actual.inspect}" }
      refute actual =~ Regex.new(Regex.escape(pattern.to_s)), msg, file, line
    end


    def assert_empty(actual, message = nil, file = __FILE__, line = __LINE__)
      if actual.responds_to?(:empty?)
        msg = -> { message || "Expected #{actual.inspect} to be empty" }
        assert actual.empty?, msg, file, line
      else
        assert_responds_to actual, :empty?
      end
    end

    def refute_empty(actual, message = nil, file = __FILE__, line = __LINE__)
      if actual.responds_to?(:empty?)
        msg = -> { message || "Expected #{actual.inspect} to not be empty" }
        refute actual.empty?, msg, file, line
      else
        assert_responds_to actual, :empty?
      end
    end


    def assert_nil(actual, message = nil, file = __FILE__, line = __LINE__)
      assert_equal nil, actual, message, file, line
    end

    def refute_nil(actual, message = nil, file = __FILE__, line = __LINE__)
      refute_equal nil, actual, message, file, line
    end


    def assert_in_delta(expected, actual, delta = 0.001, message = nil, file = __FILE__, line = __LINE__)
      n = (expected.to_f - actual.to_f).abs
      msg = -> { message || "Expected #{expected} - #{actual} (#{n}) to be <= #{delta}" }
      assert delta >= n, msg, file, line
    end

    def refute_in_delta(expected, actual, delta = 0.001, message = nil, file = __FILE__, line = __LINE__)
      n = (expected.to_f - actual.to_f).abs
      msg = -> { message || "Expected #{expected} - #{actual} (#{n}) to not be <= #{delta}" }
      refute delta >= n, msg, file, line
    end


    def assert_in_epsilon(a, b, epsilon = 0.001, message = nil, file = __FILE__, line = __LINE__)
      delta = [a.abs, b.abs].min * epsilon
      assert_in_delta a, b, delta, message, file, line
    end

    def refute_in_epsilon(a, b, epsilon = 0.001, message = nil, file = __FILE__, line = __LINE__)
      delta = a * epsilon
      refute_in_delta a, b, delta, message, file, line
    end


    def assert_includes(collection, obj, message = nil, file = __FILE__, line = __LINE__)
      msg = -> { message || "Expected #{collection.inspect} to include #{obj.inspect}" }
      if collection.responds_to?(:includes?)
        assert collection.includes?(obj), msg, file, line
      else
        assert_responds_to collection, :includes?
      end
    end

    def refute_includes(collection, obj, message = nil, file = __FILE__, line = __LINE__)
      msg = -> { message || "Expected #{collection.inspect} to not include #{obj.inspect}" }
      if collection.responds_to?(:includes?)
        refute collection.includes?(obj), msg, file, line
      else
        assert_responds_to collection, :includes?
      end
    end


    macro assert_responds_to(obj, method, message = nil, file = __FILE__, line = __LINE__)
      %msg = -> { message || "Expected #{ {{ obj }}.inspect} (#{ {{ obj }}.class.name}) to respond to ##{ {{ method }} }" }
      assert {{ obj }}.responds_to?(:{{ method.id }}), %msg, file, line
    end

    macro refute_responds_to(obj, method, message = nil, file = __FILE__, line = __LINE__)
      %msg = -> { message || "Expected #{ {{ obj }}.inspect} (#{ {{ obj }}.class.name}) to not respond to ##{ {{ method }} }" }
      refute {{ obj }}.responds_to?(:{{ method.id }}), %msg, file, line
    end


    def assert_raises(message = nil : String, file = __FILE__, line = __LINE__)
      begin
        yield
      rescue ex
        return ex
      end
      raise Assertion.new(
        message || "Expected an exception but nothing was raised",
        file: file, line: line
      )
    end

    macro assert_raises(klass, file = __FILE__, line = __LINE__)
      begin
        {{ yield }}
      rescue %ex : {{ klass.id }}
        %ex
      rescue %ex
        raise Minitest::Assertion.new(
          "Expected #{ {{ klass.id }} } but #{ %ex.class.name } was raised",
          file: {{ file }}, line: {{ line }}
        )
      else
        raise Minitest::Assertion.new(
          "Expected #{ {{ klass.id }} } but nothing was raised",
          file: {{ file }}, line: {{ line }}
        )
      end
    end


    def skip(message = "", file = __FILE__, line = __LINE__)
      raise Minitest::Skip.new(message, file: file, line: line)
    end

    def flunk(message = "Epic Fail!", file = __FILE__, line = __LINE__)
      raise Minitest::Assertion.new(message, file: file, line: line)
    end
  end
end
