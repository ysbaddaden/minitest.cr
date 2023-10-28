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
      failures.any?(Skip)
    end

    def result_code : Char
      if passed?
        '.'
      elsif skipped?
        'S'
      elsif failures.any?(Assertion)
        'F'
      else
        'E'
      end
    end

    def failure : Assertion | Skip | UnexpectedError
      failures.first
    end
  end
end
