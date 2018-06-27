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

    def run_one(name, proc)
      return unless should_run?(name)

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
