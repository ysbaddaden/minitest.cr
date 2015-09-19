module Minitest
  class Result
    getter :assertions, :failures, :class_name, :name
    property :time

    def initialize(@class_name, @name)
      @assertions = 0
      @failures = [] of Assertion | Skip | UnexpectedError
      @time :: Time::Span # avoid nilable
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
