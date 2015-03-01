require "option_parser"
require "./minitest/result"
require "./minitest/reporter"
require "./minitest/runnable"
require "./minitest/test"

module Minitest
  def self.options
    @@options ||= { verbose: false }
  end

  def self.process_args(args)
    OptionParser.parse(args) do |opts|
      opts.banner = "minitest options"

      opts.on("-h", "--help", "Display this help") do
        puts opts
        exit
      end

      opts.on("-v", "--verbose", "Show progress processing files.") do
        options[:verbose] = true
      end
    end
  end

  def self.reporter
    @@reporter ||= CompositeReporter.new.tap do |reporter|
      reporter << SummaryReporter.new(options)
      reporter << ProgressReporter.new(options)
    end
  end

  def self.reporter=(reporter)
    @@reporter = reporter
  end

  def self.run(args = nil)
    process_args(args) if args
    reporter.start

    Runnable.runnables.shuffle.each(&.run(reporter))

    reporter.report
    reporter.passed?
  end
end
