require "./assertions"

module Minitest
  module LifecycleHooks
    def before_setup
    end

    def setup
    end

    def after_setup
    end

    def before_teardown
    end

    def teardown
    end

    def after_teardown
    end
  end

  class Test < Runnable
    include LifecycleHooks
    include Assertions

    # Builds, at compile time, an Array with the test method name (String) and a
    # proc to call that method. The Array will then be shuffled at runtime.
    def self.run_tests(reporter)
      {% begin %}
        tests = [] of {String, Proc({{ @type }}, Nil)}

        {% for name in @type.methods.map(&.name).select(&.starts_with?("test_")) %}
          %proc =->(test : {{ @type }}) { test.{{ name }}; nil }
          tests << { {{ name.stringify }}, %proc }
        {% end %}

        tests.shuffle.each do |(name, proc)|
          new(reporter).run_one(name, proc)
        end
      {% end %}
      nil
    end

    def run_one(name, proc)
      case pattern = reporter.options.pattern
      when Regex  then return unless name =~ pattern
      when String then return unless name == pattern
      end

      result = Result.new(self.class.name, name)

      result.time = Time.measure do
        capture_exception(result) do
          before_setup
          setup
          after_setup
          proc.call(self)
        end

        capture_exception(result) { before_teardown }
        capture_exception(result) { teardown }
        capture_exception(result) { after_teardown }
      end

      reporter.record(result)
    end

    def capture_exception(result)
      begin
        yield
      rescue ex : Assertion | Skip
        result.failures << ex
      rescue ex : Exception
        result.failures << UnexpectedError.new(ex)
      end
    end

    def self.failures
      @@failures ||= [] of Assertion | Skip | UnexpectedError
    end
  end
end
