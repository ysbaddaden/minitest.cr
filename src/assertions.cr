require "./diff"

lib LibC
  fun dup(Int) : Int
end

class Exception
  getter __minitest_file : String?
  getter __minitest_line : Int32?

  def initialize(@message : String? = nil, @cause : Exception? = nil, @__minitest_file = __FILE__, @__minitest_line = __LINE__)
    # NOTE: hack to report the source location that raised
  end

  def __minitest_location : String
    "#{__minitest_file}:#{__minitest_line}"
  end
end

module Minitest
  module LocationFilter
    def __minitest_file : String
      file, cwd = @__minitest_file.to_s, Dir.current
      file.starts_with?(cwd) ? file[(cwd.size + 1)..-1] : file
    end
  end

  # Decorator for the original exception.
  class UnexpectedError < Exception
    include LocationFilter

    getter exception : Exception

    def initialize(@exception)
      super "#{exception.class.name}: #{exception.message}"
      @__minitest_file = exception.__minitest_file
    end

    def backtrace : Array(String)
      if pos = exception.backtrace.index(&.index("@Minitest::Test#run_tests"))
        exception.backtrace[0...pos]
      else
        exception.backtrace
      end
    end

    def __minitest_location : String
      "#{__minitest_file}:#{exception.__minitest_line}"
    end
  end

  class Assertion < Exception
    include LocationFilter
  end

  class Skip < Exception
    include LocationFilter
  end

  module Assertions
    def diff(expected : String, actual : String) : String
      diff = Diff.line_diff(expected, actual)

      String.build do |str|
        str << "--- expected\n"
        str << "+++ actual\n"

        diff.each do |delta|
          case delta.type
          when .unchanged?
            delta.a.each { |i| str << ' ' << diff.a[i] << '\n' }
          when .appended?
            delta.b.each { |i| str << '+' << diff.b[i] << '\n' }
          when .deleted?
            delta.a.each { |i| str << '-' << diff.a[i] << '\n' }
          end
        end
      end.chomp
    end

    def diff(expected, actual) : String
      left = expected.pretty_inspect.gsub("\\n", '\n') unless expected.is_a?(String)
      right = actual.pretty_inspect.gsub("\\n", '\n') unless actual.is_a?(String)
      diff(left, right)
    end

    def assert(actual, message = nil, file = __FILE__, line = __LINE__) : Bool
      return true if actual

      msg =
        case message
        when String
          message
        when Proc
          message.call
        else
          "failed assertion"
        end

      raise Minitest::Assertion.new(msg, __minitest_file: file, __minitest_line: line)
    end

    def assert(message = nil, file = __FILE__, line = __LINE__, &) : Bool
      assert yield, message, file, line
    end

    def refute(actual, message = nil, file = __FILE__, line = __LINE__) : Bool
      assert !actual, message || "failed refutation", file, line
    end

    def refute(message = nil, file = __FILE__, line = __LINE__, &) : Bool
      refute yield, message, file, line
    end

    def assert_equal(expected, actual, message = nil, file = __FILE__, line = __LINE__) : Bool
      msg = self.message(message) do
        if need_diff?(expected, actual)
          result = diff(expected, actual)
          if result.empty?
            "No visual difference found. Maybe expected class '#{expected.class.name}' isn't comparable to actual class '#{actual.class.name}' ?"
          else
            result
          end
        else
          "Expected #{expected.inspect} but got #{actual.inspect}"
        end
      end
      assert expected == actual, msg, file, line
    end

    def refute_equal(expected, actual, message = nil, file = __FILE__, line = __LINE__) : Bool
      msg = self.message(message) { "Expected #{expected.inspect} to not be equal to #{actual.inspect}" }
      assert expected != actual, msg, file, line
    end

    def assert_same(expected, actual, message = nil, file = __FILE__, line = __LINE__) : Bool
      msg = self.message(message) {
        "Expected #{actual.inspect} (oid=#{actual.object_id}) to be the same as #{expected.inspect} (oid=#{expected.object_id})"
      }
      if expected.responds_to?(:same?)
        assert expected.same?(actual), msg, file, line
      else
        assert_responds_to expected, :same?, nil, file, line
      end
    end

    def refute_same(expected, actual, message = nil, file = __FILE__, line = __LINE__) : Bool
      msg = self.message(message) {
        "Expected #{actual.inspect} (oid=#{actual.object_id}) to not be the same as #{expected.inspect} (oid=#{expected.object_id})"
      }
      if expected.responds_to?(:same?)
        refute expected.same?(actual), msg, file, line
      else
        assert_responds_to expected, :same?, nil, file, line
      end
    end

    def assert_match(pattern : Regex, actual, message = nil, file = __FILE__, line = __LINE__) : Bool
      msg = self.message(message) { "Expected #{pattern.inspect} to match: #{actual.inspect}" }
      assert actual =~ pattern, msg, file, line
    end

    def assert_match(pattern, actual, message = nil, file = __FILE__, line = __LINE__) : Bool
      msg = self.message(message) { "Expected #{pattern.inspect} to match #{actual.inspect}" }
      assert actual =~ Regex.new(Regex.escape(pattern.to_s)), msg, file, line
    end

    def refute_match(pattern : Regex, actual, message = nil, file = __FILE__, line = __LINE__) : Bool
      msg = self.message(message) { "Expected #{pattern.inspect} to not match #{actual.inspect}" }
      refute actual =~ pattern, msg, file, line
    end

    def refute_match(pattern, actual, message = nil, file = __FILE__, line = __LINE__) : Bool
      msg = self.message(message) { "Expected #{pattern.inspect} to not match #{actual.inspect}" }
      refute actual =~ Regex.new(Regex.escape(pattern.to_s)), msg, file, line
    end

    def assert_empty(actual, message = nil, file = __FILE__, line = __LINE__) : Bool
      if actual.responds_to?(:empty?)
        msg = self.message(message) { "Expected #{actual.inspect} to be empty" }
        assert actual.empty?, msg, file, line
      else
        assert_responds_to actual, :empty?
      end
    end

    def refute_empty(actual, message = nil, file = __FILE__, line = __LINE__) : Bool
      if actual.responds_to?(:empty?)
        msg = self.message(message) { "Expected #{actual.inspect} to not be empty" }
        refute actual.empty?, msg, file, line
      else
        assert_responds_to actual, :empty?
      end
    end

    def assert_nil(actual, message = nil, file = __FILE__, line = __LINE__) : Bool
      assert_equal nil, actual, message, file, line
    end

    def refute_nil(actual, message = nil, file = __FILE__, line = __LINE__) : Bool
      refute_equal nil, actual, message, file, line
    end

    def assert_in_delta(expected : Number, actual : Number, delta : Number = 0.001, message = nil, file = __FILE__, line = __LINE__) : Bool
      n = (expected.to_f - actual.to_f).abs
      msg = self.message(message) { "Expected #{expected} - #{actual} (#{n}) to be <= #{delta}" }
      assert delta >= n, msg, file, line
    end

    def refute_in_delta(expected : Number, actual : Number, delta : Number = 0.001, message = nil, file = __FILE__, line = __LINE__) : Bool
      n = (expected.to_f - actual.to_f).abs
      msg = self.message(message) { "Expected #{expected} - #{actual} (#{n}) to not be <= #{delta}" }
      refute delta >= n, msg, file, line
    end

    def assert_in_epsilon(a : Number, b : Number, epsilon : Number = 0.001, message = nil, file = __FILE__, line = __LINE__) : Bool
      delta = [a.to_f.abs, b.to_f.abs].min * epsilon
      assert_in_delta a, b, delta, message, file, line
    end

    def refute_in_epsilon(a : Number, b : Number, epsilon : Number = 0.001, message = nil, file = __FILE__, line = __LINE__) : Bool
      delta = a.to_f * epsilon
      refute_in_delta a, b, delta, message, file, line
    end

    def assert_includes(collection, obj, message = nil, file = __FILE__, line = __LINE__) : Bool
      msg = self.message(message) { "Expected #{collection.inspect} to include #{obj.inspect}" }
      if collection.responds_to?(:includes?)
        assert collection.includes?(obj), msg, file, line
      else
        assert_responds_to collection, :includes?
      end
    end

    def refute_includes(collection, obj, message = nil, file = __FILE__, line = __LINE__) : Bool
      msg = self.message(message) { "Expected #{collection.inspect} to not include #{obj.inspect}" }
      if collection.responds_to?(:includes?)
        refute collection.includes?(obj), msg, file, line
      else
        assert_responds_to collection, :includes?
      end
    end

    def assert_instance_of(cls, obj, message = nil, file = __FILE__, line = __LINE__) : Bool
      msg = self.message(message) do
        "Expected #{obj.inspect} to be an instance of #{cls.name}, not #{obj.class.name}"
      end
      assert cls === obj, msg, file, line
    end

    def refute_instance_of(cls, obj, message = nil, file = __FILE__, line = __LINE__) : Bool
      msg = self.message(message) do
        "Expected #{obj.inspect} to not be an instance of #{cls.name}"
      end
      refute cls === obj, msg, file, line
    end

    macro assert_responds_to(obj, method, message = nil, file = __FILE__, line = __LINE__)
      %msg = self.message({{ message }}) do
        "Expected #{ {{ obj }}.inspect} (#{ {{ obj }}.class.name}) to respond to ##{ {{ method }} }"
      end
      assert {{ obj }}.responds_to?(:{{ method.id }}), %msg, {{ file }}, {{ line }}
    end

    macro refute_responds_to(obj, method, message = nil, file = __FILE__, line = __LINE__)
      %msg = self.message({{ message }}) do
        "Expected #{ {{ obj }}.inspect} (#{ {{ obj }}.class.name}) to not respond to ##{ {{ method }} }"
      end
      refute {{ obj }}.responds_to?(:{{ method.id }}), %msg, {{ file }}, {{ line }}
    end

    def assert_raises(message : String? = nil, file = __FILE__, line = __LINE__, &) : Exception
      yield
    rescue ex
      ex
    else
      message ||= "Expected an exception but nothing was raised"
      raise Assertion.new(message, __minitest_file: file, __minitest_line: line)
    end

    def assert_raises(klass : T.class, file = __FILE__, line = __LINE__, &) : T forall T
      yield
    rescue ex : T
      ex
    rescue ex
      message = "Expected #{T.name} but #{ex.class.name} was raised"
      raise Assertion.new(message, __minitest_file: file, __minitest_line: line)
    else
      message = "Expected #{T.name} but nothing was raised"
      raise Assertion.new(message, __minitest_file: file, __minitest_line: line)
    end

    def assert_silent(file = __FILE__, line = __LINE__, &) : Bool
      assert_output("", "", file, line) do
        yield
      end
    end

    def assert_output(stdout = nil, stderr = nil, file = __FILE__, line = __LINE__, &) : Bool
      output, error = capture_io { yield }

      o = stdout.is_a?(Regex) ? assert_match(stdout, output) : assert_equal(stdout, output) if stdout
      e = stderr.is_a?(Regex) ? assert_match(stderr, error) : assert_equal(stderr, error) if stderr

      (!stdout || !!o) && (!stderr || !!e)
    end

    def capture_io(& : ->) : {String, String}
      # prevents a reporter from printing any output from another thread,
      # also prevents parallel calls to `capture_io`:
      @__reporter.pause

      File.tempfile("out") do |stdout|
        File.tempfile("err") do |stderr|
          reopen(STDOUT, stdout) do
            reopen(STDERR, stderr) do
              yield
            end
          end
          return {
            stdout.rewind.gets_to_end,
            stderr.rewind.gets_to_end,
          }
        ensure
          stderr.delete
        end
      ensure
        stdout.delete
      end
      raise "unreachable"
    ensure
      @__reporter.resume
    end

    private def reopen(src, dst, & : ->) : Nil
      if (backup_fd = LibC.dup(src.fd)) == -1
        raise IO::Error.from_errno("dup")
      end

      begin
        src.reopen(dst)
        yield
        src.flush
      ensure
        if LibC.dup2(backup_fd, src.fd) == -1
          raise IO::Error.from_errno("dup")
        end
        LibC.close(backup_fd)
      end
    end

    def skip(message = "", file = __FILE__, line = __LINE__) : NoReturn
      raise Minitest::Skip.new(message.to_s, __minitest_file: file, __minitest_line: line)
    end

    def flunk(message = "Epic Fail!", file = __FILE__, line = __LINE__) : NoReturn
      raise Minitest::Assertion.new(message.to_s, __minitest_file: file, __minitest_line: line)
    end

    def message(message : Nil, &block : -> String) : -> String
      block
    end

    def message(message : String, &block : -> String) : -> String
      if message.blank?
        block
      else
        -> { "#{message}\n#{block.call}" }
      end
    end

    def message(message : Proc(String), &block : -> String) : -> String
      -> { "#{message.call}\n#{block.call}" }
    end

    private def need_diff?(expected, actual) : Bool
      need_diff?(expected.inspect) &&
        need_diff?(actual.inspect)
    end

    private def need_diff?(obj : String) : Bool
      !!obj.index("") && obj.size > 30
    end
  end
end
