require "tempfile"

class Exception
  getter file : String?
  getter line : Int32?
  getter! backtrace : Array(String)

  def initialize(@message : String? = nil, @cause : Exception? = nil, @file = __FILE__, @line = __LINE__)
    # NOTE: hack to report the source location that raised
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
      file, cwd = @file.to_s, Dir.current
      file.starts_with?(cwd) ? file[(cwd.size + 1) .. -1] : file
    end
  end

  # Decorator for the original exception.
  class UnexpectedError < Exception
    include LocationFilter

    getter exception : Exception

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
    @@diff : Bool?

    def self.diff?
      if (diff = @@diff).is_a?(Bool)
        diff
      else
        @@diff = Process.new("diff").wait.success?
      end
    end

    def diff(expected, actual)
      a = Tempfile.open("a") { |f| f << expected.inspect.gsub("\\n", '\n') << '\n' }
      b = Tempfile.open("b") { |f| f << actual.inspect.gsub("\\n", '\n') << '\n' }

      Process.run("diff", {"-u", a.path, b.path}) do |process|
        process.output.gets_to_end
          .sub(/^--- [^\n]*/m, "--- expected")
          .sub(/^\+\+\+ [^\n]*/m, "+++ actual")
          .strip
      end
    ensure
      if a; a.delete; end
      if b; b.delete; end
    end

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
      msg = -> {
        if need_diff?(expected, actual)
          result = diff(expected, actual)
          if result.empty?
            "No visual difference found. Maybe expected class '#{expected.class.name}' isn't comparable to actual class '#{actual.class.name}' ?"
          else
            result
          end
        else
          message || "Expected #{expected.inspect} but got #{actual.inspect}"
        end
      }
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
      msg = -> { message || "Expected #{pattern.inspect} to match: #{actual.inspect}" }
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


    def assert_raises(message : String? = nil, file = __FILE__, line = __LINE__)
      begin
        yield
      rescue ex
        ex
      else
        message ||= "Expected an exception but nothing was raised"
        raise Assertion.new(message, file: file, line: line)
      end
    end

    def assert_raises(klass : T.class, file = __FILE__, line = __LINE__) forall T
      begin
        yield
      rescue ex : T
        ex
      rescue ex
        message = "Expected #{ T.name } but #{ ex.class.name } was raised"
        raise Assertion.new(message, file: file, line: line)
      else
        message = "Expected #{ T.name } but nothing was raised"
        raise Assertion.new(message, file: file, line: line)
      end
    end


    def skip(message = "", file = __FILE__, line = __LINE__)
      raise Minitest::Skip.new(message.to_s, file: file, line: line)
    end

    def flunk(message = "Epic Fail!", file = __FILE__, line = __LINE__)
      raise Minitest::Assertion.new(message.to_s, file: file, line: line)
    end


    private def need_diff?(expected, actual)
      return false unless expected.is_a?(String)
      return false unless actual.is_a?(String)

      return Minitest::Assertions.diff? ||
        expected.index('\n') || actual.index('\n') ||
        expected.size > 30 || actual.size > 30
    end
  end
end
