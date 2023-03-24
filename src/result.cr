module Minitest
  class Result
    getter assertions : Int64
    getter class_name : String
    getter failures : Array(Assertion | Skip | UnexpectedError)
    getter name : String
    property! time : Time::Span

    def initialize(@class_name : String, @name : String)
      @assertions = 0
      @failures = [] of Assertion | Skip | UnexpectedError
    end

    def passed? : Bool
      failures.empty?
    end

    def skipped? : Bool
      failures.any?(&.is_a?(Skip))
    end

    def result_code : Char
      return '.' if passed?
      return 'S' if skipped?
      return 'F' if failures.any?(&.is_a?(Assertion))
      return 'E'
    end

    def failure : Assertion | Skip | UnexpectedError
      failures.first
    end
  end
end
