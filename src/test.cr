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

    def self.run_tests(reporter)
      {% begin %}
        {% names = @type.methods.map(&.name).select(&.starts_with?("test_")) %}

        {% for name in names.shuffle %}
          %test = new(reporter)
          %test.run_one({{ name.stringify }}) { %test.{{ name }} }
        {% end %}
      {% end %}

      nil
    end

    def run_one(name)
      case pattern = reporter.options.pattern
      when Regex  then return unless name =~ pattern
      when String then return unless name == pattern
      end

      result = Result.new(self.class.name, name)
      start_time = Time.now

      capture_exception(result) do
        before_setup
        setup
        after_setup

        yield
      end

      capture_exception(result) { before_teardown }
      capture_exception(result) { teardown }
      capture_exception(result) { after_teardown }

      result.time = Time.now - start_time
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
