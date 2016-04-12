module Minitest
  class Result
    getter assertions
    getter class_name : String
    getter failures
    getter name : String
    property! time : Time::Span

    def initialize(@class_name, @name)
      @assertions = 0
      @failures = [] of Assertion | Skip | UnexpectedError
    end

    def passed?
      failures.empty?
    end

    def skipped?
      failures.any?(&.is_a?(Skip))
    end

    def result_code
      return "." if passed?
      return "S" if skipped?
      return "F" if failures.any?(&.is_a?(Assertion))
      return "E"
    end

    def failure
      failures.first
    end
  end
end
