class Exception
  getter :file, :line

  # NOTE: hack to report the source location that raised
  def initialize(@message = nil : String?, @cause = nil : Exception?, @file = __FILE__, @line = __LINE__)
    @backtrace = caller
  end

  def location
    "#{file}:#{line}"
  end

  # NOTE: hack to avoid segfault on calling "obj.class"
  #       https://github.com/manastech/crystal/issues/416
  macro def __minitest_class_name : String
    {{ @class_name }}
  end
end

module Minitest
  module LocationFilter
    def file
      file = @file.to_s
      cwd = Dir.working_directory
      file.starts_with?(cwd) ? file[(cwd.size + 1) .. -1] : file
    end
  end

  # Decorator for the original exception.
  class UnexpectedError < Exception
    include LocationFilter

    getter :exception

    def initialize(@exception)
      super "#{class_name}: #{exception.message}"
      @file = exception.file
    end

    def class_name
      exception.__minitest_class_name
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

  # TODO: assert_includes / refute_includes
  # TODO: assert_in_delta / refute_in_delta
  # TODO: assert_in_epsilon / refute_in_epsilon
  # TODO: assert_nil / refute_nil
  # TODO: assert_output / refute_output
  # TODO: assert_same / refute_same
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
      msg = -> { message || "Expected #{actual.inspect} to be empty" }
      assert actual.empty?, msg, file, line
    end

    def refute_empty(actual, message = nil, file = __FILE__, line = __LINE__)
      msg = -> { message || "Expected #{actual.inspect} to not be empty" }
      refute actual.empty?, msg, file, line
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
      rescue __minitest_ex : {{ klass.id }}
        __minitest_ex
      rescue __minitest_ex
        raise Minitest::Assertion.new(
          "Expected #{ {{klass.id}} } but #{__minitest_ex.__minitest_class_name} was raised",
          file: {{ file }}, line: {{ line }}
        )
      else
        raise Minitest::Assertion.new(
          "Expected #{ {{klass.id}} } but nothing was raised",
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
