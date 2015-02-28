require "./minitest/reporter"
require "./minitest/runnable"
require "./minitest/test"

module Minitest
  class Result
    getter :assertions, :failures, :class_name, :name
    property :time

    def initialize(@class_name, @name)
      @assertions = 0
      @failures = [] of Assertion | Skip | UnexpectedError
      @time :: TimeSpan # avoid nilable
    end

    def passed?
      failures.empty?
    end

    def skipped?
      failures.any? { |f| f.is_a?(Skip) }
    end

    def result_code
      return "." if passed?
      return "S" if skipped?
      return "E" if failures.any? { |f| f.is_a?(UnexpectedError) }
      return "F"
    end

    def failure
      failures.first
    end
  end

  # TODO: parse command line option --verbose
  def self.options
    @@options ||= { verbose: false }
  end

  def self.run
    reporter = CompositeReporter.new
    reporter << SummaryReporter.new(options)
    reporter << ProgressReporter.new(options)
    reporter.start

    Runnable.runnables.shuffle.each(&.run(reporter))

    reporter.report
    reporter.passed?
  end
end
