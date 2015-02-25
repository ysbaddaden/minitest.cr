require "./minitest/reporter"
require "./minitest/runnable"
require "./minitest/test"

module Minitest
  macro def self.run : Bool
    reporter = Reporter.new
    reporter.start

    Runnable.runnables.shuffle.each(&.run)

    reporter.report
    reporter.passed?
  end
end
