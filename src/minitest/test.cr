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
      {{ @type.methods.map(&.name.stringify).select(&.starts_with?("test_")).map { |m| "run_one { #{m.id} }" }.join("\n").id }}
      nil
    end

    def run_one
      capture_exception do
        before_setup
        setup
        after_setup

        yield
      end

      capture_exception { before_teardown }
      capture_exception { teardown }
      capture_exception { after_teardown }
    end

    def capture_exception
      begin
        yield
      rescue ex : Assertion
        self.class.failures << ex
      rescue ex : Exception
        self.class.failures << UnexpectedError.new(ex)
      end
    end

    def self.failures
      @@failures ||= [] of Assertion | UnexpectedError
    end
  end
end
