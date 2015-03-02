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

  # FIXME: hack to avoid https://github.com/manastech/crystal/issues/416
  class ::Exception
    macro def __minitest_class_name : String
      {{ @class_name }}
    end
  end

  class UnexpectedError < Exception
    getter :exception

    def initialize(@exception)
      super "#{original_class_name}: #{exception.message}"
    end

    def original_class_name
      exception.__minitest_class_name
    end

    def original_backtrace
      if pos = exception.backtrace.index { |f| f.index("@Minitest::Test#run_tests") }
        exception.backtrace[0 ... pos]
      else
        exception.backtrace
      end
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
          #.shuffle
          .map { |m| "run_one(#{m}) { #{m.id} }" }
          .join("\n")
          .id
      }}
      nil
    end

    def run_one(name)
      result = Result.new(self.class.to_s, name)
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
