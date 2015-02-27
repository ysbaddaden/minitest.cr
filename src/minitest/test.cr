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

  class UnexpectedError < Exception
    getter :exception

    def initialize(@exception)
      super "Unexpected error: #{exception}"
    end
  end

  class Test < Runnable
    include LifecycleHooks
    include Assertions

    # TODO: shuffle test methods
    macro def run_tests : Nil
      {{
        @type.methods
          .map(&.name.stringify)
          .select(&.starts_with?("test_"))
          .map { |m| "run_one { #{m.id} }" }
          .join("\n")
          .id
      }}
      nil
    end

    def run_one
      result = Result.new

      capture_exception(result) do
        before_setup
        setup
        after_setup

        yield
      end

      capture_exception(result) { before_teardown }
      capture_exception(result) { teardown }
      capture_exception(result) { after_teardown }

      reporter.record(result)
    end

    def capture_exception(result)
      begin
        yield
      rescue ex : Assertion
        result.failures << ex
      rescue ex : Skip
        result.skipped = ex.message
      rescue ex : Exception
        result.failures << UnexpectedError.new(ex)
      end
    end

    def self.failures
      @@failures ||= [] of Assertion | UnexpectedError
    end
  end
end
